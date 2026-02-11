#!/bin/bash
set -e

# --- Configuration & Defaults ---
YAML_CFG="image.yaml"
DRY_RUN=false
# --- Module: Configuration Loader ---

# This function loads the JSON configuration and resolves variables in a controlled manner.
# --- Module: The Smart Resolver ---
# This is the "Brain" that makes YAML self-resolving
# --- Revised Module: The Smart Resolver ---
# --- Revised Module: The Smart Resolver ---
resolve_json() {
    local input_file="$1"
    [[ ! -f "$input_file" ]] && { echo "File not found: $input_file"; exit 1; }

    local current_state=$(cat "$input_file")
    local last_state=""

    while [[ "$current_state" != "$last_state" ]]; do
        last_state="$current_state"

        # FIXED LOGIC: 
        # 1. We filter out paths where the 'last' element is a number (array index).
        # 2. This ensures we only export actual named keys.
        while read -r kv_pair; do
            if [[ -n "$kv_pair" ]]; then
                export "$kv_pair"
            fi
        done < <(echo "$current_state" | jq -r '
            paths(scalars) as $p 
            | select($p[-1] | type != "number") 
            | "\($p | last)=\(getpath($p))" 
            | select(contains("$") | not)
        ')

        current_state=$(echo "$current_state" | envsubst)
    done

    # Validation (same as before)
    local leftovers=$(echo "$current_state" | grep -oP '\$(?!\{?\( )[a-zA-Z0-9_{}]+' | grep -vP '\$\(' || true)
    if [[ -n "$leftovers" ]]; then
        echo ">>> FATAL: Could not resolve: $leftovers"
        exit 1
    fi

    RESOLVED_JSON_DATA="$current_state"
}

# Now get_val is super simple and fast
get_val() {
    echo "$RESOLVED_YAML" | yq -r "$1"
}

# --- Module 1: Usage & Argument Parsing ---
usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "A modular Docker Buildx wrapper that reads configuration from $YAML_CFG."
    echo ""
    echo "Options:"
    echo "  -d, --dry-run    Parse JSON and print the final command without executing."
    echo "  -h, --help       Display this help message and exit."
    echo ""
    exit 0
}

parse_args() {
    # If no arguments are passed, it defaults to DRY_RUN=false
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -h|--help)
                usage
                ;;
            *)
                echo "Error: Unknown option '$1'"
                usage
                ;;
        esac
    done
}

# --- Module 2: Data Loading ---
# --- Module 2: Data Loading ---
load_config() {
    
    # 1. Local Environment
    LOCAL_CACHE_PATH="/mnt/wsl/disk2/.buildkit-cache"
    
    # 2. Extract JSON values
    BUILDER_NAME=$(get_val '.builder.name')
    BUILDER_DRIVER=$(get_val '.builder.driver')
    CONTEXT=$(get_val '.build.context')
    DOCKERFILE=$(get_val '.build.dockerfile')
    TAGS=$(get_val '.build.tags')
    OUTPUT=$(get_val '.build.outputs[0]')
    
    # 3. Cache Logic
    CACHE_TYPE=$(get_val '.build.cacheArgs.type')
    CACHE_MODE=$(get_val '.build.cacheArgs.mode')
    AUTO_CLEAN=$(get_val '.build.cacheArgs.cleanOldCaches')

    # Resolve nested variables in paths
    RAW_SRC=$(get_val '.build.cacheArgs.src')
    CACHE_SRC=$(echo "$RAW_SRC" | sed "s|\${tags}|$TAGS|g" | sed "s|\${localCachePath}|$LOCAL_CACHE_PATH|g")

    if [ "$AUTO_CLEAN" = "on" ]; then
        RAW_DEST=$(get_val '.build.cacheArgs.dest')
        CACHE_DEST=$(echo "$RAW_DEST" | sed "s|\${tags}|$TAGS|g" | sed "s|\${localCachePath}|$LOCAL_CACHE_PATH|g")
    else
        # If AUTO_CLEAN is off, read and write to the same source (Incremental)
        CACHE_DEST="$CACHE_SRC"
    fi

    # 4. Build Arguments
    BUILD_ARGS=()
    while read -r key value; do
        BUILD_ARGS+=("--build-arg" "$key=$(eval echo "$value")")
    done < <(jq -r '.build.buildArgs | to_entries[] | "\(.key) \(.value)"' "$YAML_CFG")
}

# --- Module 3: Execution ---
run_build() {
    local CMD="docker buildx build \
        --pull=false \
        --progress=plain \
        --load \
        --file $DOCKERFILE \
        --tag $TAGS \
        ${BUILD_ARGS[*]} \
        --cache-from type=$CACHE_TYPE,src=$CACHE_SRC \
        --cache-to type=$CACHE_TYPE,dest=$CACHE_DEST,mode=$CACHE_MODE \
        --output $OUTPUT \
        $CONTEXT"

    if [ "$DRY_RUN" = true ]; then
        echo " [DRY RUN] Resolved JSON Configuration: "
        echo "$RESOLVED_JSON" | jq .  # Pretty print the resolved JSON for debugging
        echo -e "\n=== [DRY RUN] Generated Build Command ===\n"
        echo "$CMD" | sed -r 's/[[:space:]]{2,}/\n  /g'
        echo -e "\n==========================================\n"
        exit 0
    fi

    # Ensure builder is ready
    docker buildx use "$BUILDER_NAME" || docker buildx create --name "$BUILDER_NAME" --driver "$BUILDER_DRIVER" --use
    
    echo ">>> Executing Build..."
    eval "$CMD"
    echo ">>> Build successfull."
}

# --- Module 4: Post-Build Cache Management ---
rotate_cache() {
    if [ "$AUTO_CLEAN" = "on" ]; then
        echo ">>> Rotating cache: $CACHE_DEST -> $CACHE_SRC"
        rm -rf "$CACHE_SRC"
        mv "$CACHE_DEST" "$CACHE_SRC"
        mkdir -p "$CACHE_DEST"
    fi
}

# --- Main Entry Point ---
main() {
    parse_args "$@"
    resolve_yaml "$YAML_CFG"
    load_config
    run_build
    rotate_cache
    echo ""
    echo "Push the image with:"
    echo "  docker push $TAGS"
    echo ""
    echo "Done."
}

main "$@"

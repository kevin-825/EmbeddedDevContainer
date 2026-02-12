#!/bin/bash
source ../json_resolve_scripts/shell_exception_handling_core/exception_handling_core.sh

# --- Configuration & Defaults ---
JSON_CFG="image.json"
jSON_RESOLVER="../../json_resolve_scripts/resolver.sh"
DRY_RUN=false
RESOLVED_JSON_DATA=""

cleanup_outdated_caches() {
    # Match the JSON key exactly: cleanOldCaches
    local auto_clean
    local cache_src
    local cache_dest
    auto_clean=$($jSON_RESOLVER "$JSON_CFG" 'build.cacheArgs.autoCleanOldCaches')
    cache_src=$($jSON_RESOLVER "$JSON_CFG" 'build.cacheArgs.cacheSrc')
    cache_dest=$($jSON_RESOLVER "$JSON_CFG" 'build.cacheArgs.cacheDest')

    if [[ "$auto_clean" == "on" ]] || [[ "$auto_clean" == "yes" ]]; then
        if [[ "$cache_src" != "$cache_dest" ]]; then
            echo ">>> [INFO] Rotating cache: Moving $cache_dest ==> $cache_src"
            
            # Remove old source
            rm -rf "$cache_src"
            
            # Move new destination to source if it exists
            if [[ -d "$cache_dest" ]]; then
                mv "$cache_dest" "$cache_src"
            else
                echo ">>> [WARN] Cache destination $cache_dest not found. Nothing to rotate."
            fi
        else
            echo ">>> [INFO] Cache source and destination are identical. No rotation needed."
        fi
    fi
}

# --- Module: Docker Command Generator ---
# @description: Converts RESOLVED_JSON_DATA into a bash array and a pretty-print string.
generate_docker_image_build_command() {

    #local options=$(../json_resolve_scripts/resolver.sh '$JSON_CFG' '.build.options[]')
    local CMD
    CMD=$($jSON_RESOLVER "$JSON_CFG" 'build.cmd')

    echo -e ">>> [INFO] Full Docker command:\n $CMD " | sed -r 's/[[:space:]]{4,}/    \n  /g'


    if [[ -n "$CMD" ]]; then
        DOCKER_CMD=($CMD)
    else
        DOCKER_CMD=()
    fi

    #for opt in $options; do
    #    DOCKER_CMD+=("$opt")
    #done
}

# --- Module: Command Executor ---
# @description: Executes the generated Docker command or simulates it.
run_build() {
    if [[ "$DRY_RUN" = true ]]; then
        echo ">>> [DRY RUN] Skipping execution."
    else
        echo ">>> Starting Docker Build..."
        # The quote syntax below is CRITICAL. 
        # It treats each array element as a separate, protected argument.
        "${DOCKER_CMD[@]}"
        
        # Check if the command succeeded
        if [[ $? -eq 0 ]]; then
            cleanup_outdated_caches
            local imgName
            imgName=$($jSON_RESOLVER "$JSON_CFG" 'build.imgName')
            echo ">>> Build $imgName completed successfully."
            #create_container.sh $imgName dev0 -y
        else
            echo ">>> ERROR: Docker build failed."
            exit 1
        fi
    fi
}

# --- Argument Parsing & Main ---
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--dry-run) DRY_RUN=true; shift ;;
            *) echo "Error: Unknown option '$1'"; exit 1 ;;
        esac
    done
}

main() {
    parse_args "$@"

    generate_docker_image_build_command

    run_build
}

main "$@"

#!/bin/bash

set -euo pipefail  # Fail fast and safely

#####################################################################
# Script: mover-start-qbit.sh
# Description: Starts qBittorrent docker container after Unraid mover completes
# Author: @ggfevans
# Date: 2025-02-16
# Usage: ./mover-start-qbit.sh
#####################################################################

# Configuration
readonly CONTAINER_NAME="qbittorrent"
readonly LOG_DIR="/var/log/mover"
readonly LOG_FILE="${LOG_DIR}/mover-start-qbit.log"
readonly MAX_RETRIES=3
readonly RETRY_DELAY=5

# Signal handling
cleanup() {
    log_message "Script interrupted, exiting..."
    exit 1
}
trap cleanup SIGINT SIGTERM

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "${LOG_FILE}"
}

# Function to check prerequisites
check_prerequisites() {
    # Check log directory
    mkdir -p "${LOG_DIR}" || {
        echo "ERROR: Cannot create log directory ${LOG_DIR}"
        exit 1
    }

    # Check Docker
    if ! docker info >/dev/null 2>&1; then
        log_message "ERROR: Docker is not running"
        exit 1
    }

    # Check if container exists
    if ! docker container inspect "${CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: Container ${CONTAINER_NAME} does not exist"
        exit 1
    }
}

# Function to start container with retries
start_container() {
    if is_container_running; then
        log_message "Container ${CONTAINER_NAME} is already running"
        return 0
    }

    local retry_count=0
    while [ $retry_count -lt $MAX_RETRIES ]; do
        log_message "Starting ${CONTAINER_NAME} (attempt $((retry_count + 1))/${MAX_RETRIES})"
        
        if docker start "${CONTAINER_NAME}"; then
            log_message "Successfully started ${CONTAINER_NAME}"
            return 0
        fi
        
        retry_count=$((retry_count + 1))
        [ $retry_count -lt $MAX_RETRIES ] && {
            log_message "Retrying in ${RETRY_DELAY} seconds..."
            sleep "${RETRY_DELAY}"
        }
    done

    return 1
}

# Function to check if container is running
is_container_running() {
    docker ps --quiet --filter name="^/${CONTAINER_NAME}$" | grep -q .
}

# Main execution
main() {
    check_prerequisites
    start_container || {
        log_message "ERROR: Failed to start ${CONTAINER_NAME} after ${MAX_RETRIES} attempts"
        exit 1
    }
}

main
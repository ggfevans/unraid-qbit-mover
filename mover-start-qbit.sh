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
    if ! mkdir -p "${LOG_DIR}"; then
        log_message "ERROR: Cannot create log directory ${LOG_DIR}"
        exit 1
    fi

    # Check Docker
    if ! docker info >/dev/null 2>&1; then
        log_message "ERROR: Docker is not running"
        exit 1
    fi

    # Check if container exists
    if ! docker container inspect "${CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: Container ${CONTAINER_NAME} does not exist"
        exit 1
    fi
}

# Function to start container with retries
start_container() {
    local retry_count=0
    
    if is_container_running; then
        log_message "Container ${CONTAINER_NAME} is already running"
        return 0
    fi

    while [ $retry_count -lt $MAX_RETRIES ]; do
        if docker start "${CONTAINER_NAME}"; then
            log_message "Successfully started ${CONTAINER_NAME}"
            return 0
        fi
        
        retry_count=$((retry_count + 1))
        log_message "Retry ${retry_count}/${MAX_RETRIES} failed, waiting ${RETRY_DELAY} seconds..."
        sleep "${RETRY_DELAY}"
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
    if ! start_container; then
        log_message "ERROR: Failed to start ${CONTAINER_NAME} after ${MAX_RETRIES} attempts"
        exit 1
    fi
}

main
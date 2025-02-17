#!/bin/bash

set -euo pipefail  # Fail fast and safely

#####################################################################
# Script: mover-stop-qbit.sh
# Description: Gracefully stops qBittorrent docker container for Unraid mover
# Author: @ggfevans
# Date: 2025-02-16
# Usage: ./mover-stop-qbit.sh
#####################################################################

# Configuration
readonly CONTAINER_NAME="qbittorrent"
readonly LOG_DIR="/var/log/mover"
readonly LOG_FILE="${LOG_DIR}/mover-stop-qbit.log"
readonly TIMEOUT=30

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
        echo "ERROR: Cannot create log directory ${LOG_DIR}"
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

# Function to stop container
stop_container() {
    if ! docker ps --quiet --filter name="^/${CONTAINER_NAME}$" | grep -q .; then
        log_message "Container ${CONTAINER_NAME} not running"
        return 0
    }

    log_message "Stopping ${CONTAINER_NAME} container"
    if docker stop --time="${TIMEOUT}" "${CONTAINER_NAME}"; then
        log_message "Successfully stopped ${CONTAINER_NAME}"
        return 0
    fi
    return 1
}

# Main execution
main() {
    check_prerequisites
    stop_container || {
        log_message "ERROR: Failed to stop ${CONTAINER_NAME}"
        exit 1
    }
}

main
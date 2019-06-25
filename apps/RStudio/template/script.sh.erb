#!/usr/bin/env bash

# Load the required environment
setup_env () {
  # Additional environment which could be moved into a module
  # Change these to suit
  export RSTUDIO_SERVER_IMAGE="/apps/rserver-launcher-centos7.simg"
  export SINGULARITY_BINDPATH="/etc,/media,/mnt,/opt,/srv,/usr,/var"
  export PATH="$PATH:/usr/lib/rstudio-server/bin"
  export SINGULARITYENV_PATH="$PATH"
}
setup_env

#
# Start RStudio Server
#

# PAM auth helper used by RStudio
export RSTUDIO_AUTH="${PWD}/bin/auth"

# Generate an `rsession` wrapper script
export RSESSION_WRAPPER_FILE="${PWD}/rsession.sh"
(
umask 077
sed 's/^ \{2\}//' > "${RSESSION_WRAPPER_FILE}" << EOL
  #!/usr/bin/env bash

  # Log all output from this script
  export RSESSION_LOG_FILE="${PWD}/rsession.log"

  exec &>>"\${RSESSION_LOG_FILE}"

  # Launch the original command
  echo "Launching rsession..."
  set -x
  exec rsession --r-libs-user "${R_LIBS_USER}" "\${@}"
EOL
)
chmod 700 "${RSESSION_WRAPPER_FILE}"

# Set working directory to home directory
cd "${HOME}"

export TMPDIR="$(mktemp -d)"

mkdir -p "$TMPDIR/rstudio-server"
python -c 'from uuid import uuid4; print(uuid4())' > "$TMPDIR/rstudio-server/secure-cookie-key"
chmod 0600 "$TMPDIR/rstudio-server/secure-cookie-key"

set -x
# Launch the RStudio Server
echo "Starting up rserver..."

singularity run -B "$TMPDIR:/tmp" "$RSTUDIO_SERVER_IMAGE" \
 --www-port "${port}" \
 --auth-none 0 \
 --auth-pam-helper-path "${RSTUDIO_AUTH}" \
 --auth-encrypt-password 0 \
 --rsession-path "${RSESSION_WRAPPER_FILE}"

echo 'Singularity as exited...'

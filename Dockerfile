FROM oschwengers/bakta:v1.12.0

# Reference data (Bakta DB v6) is mounted by CTS at /ref_data
# After CTS unpacks the bundle, the database lives at /ref_data/db/
ENV BAKTA_DB /ref_data/db

# Bakta is installed via conda at /opt/conda/bin/bakta but conda's bin
# directory is not on the runtime PATH that runc exec sees, so we use
# the absolute path here. Without this, CTS jobs fail with:
#   "exec: \"bakta\": executable file not found in $PATH"
ENTRYPOINT ["/opt/conda/bin/bakta"]

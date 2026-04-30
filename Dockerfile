FROM oschwengers/bakta:v1.12.0

# Reference data (Bakta DB v6) is mounted by CTS at /ref_data
# After CTS unpacks the bundle, the database lives at /ref_data/db/
ENV BAKTA_DB /ref_data/db

# CTS requires an entrypoint
ENTRYPOINT ["bakta"]

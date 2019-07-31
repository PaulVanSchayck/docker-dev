#!/usr/bin/env bash

############
## Resources

# Create coordination- and child-resources for project data
iadmin mkresc UM-Ceph-S3-AC s3 `hostname`:/dh-irods-bucket-dev \"S3_DEFAULT_HOSTNAME=minio1:9000;S3_AUTH_FILE=/var/lib/irods/minio1.keypair;S3_REGIONNAME=irods-dev;S3_RETRY_COUNT=1;S3_WAIT_TIME_SEC=3;S3_PROTO=HTTP;ARCHIVE_NAMING_POLICY=consistent;HOST_MODE=cacheless_attached;S3_CACHE_DIR=/cache\"
iadmin mkresc replRescUMCeph01 replication
iadmin addchildtoresc replRescUMCeph01 UM-Ceph-S3-AC

# Add comment to resource for better identification in pacman's createProject dropdown
iadmin modresc ${HOSTNAME}Resource comment DO-NOT-USE
iadmin modresc replRescUMCeph01 comment Replicated-resource-for-S3

###########
## Projects and project permissions
domain="maastrichtuniversity.nl"

for i in {01..2}; do
    PROJECTNAME=$(fortune | head -n 1 | sed 's/\x27/ /g')
    project=$(irule -F /rules/projects/createProject.r "*authorizationPeriodEndDate='1-1-2018'" "*dataRetentionPeriodEndDate='1-1-2018'" "*ingestResource='iresResource'" "*resource='replRescUMCeph01'" "*storageQuotaGb='10'" "*title='(s3) ${PROJECTNAME}'" "*principalInvestigator='p.suppers@${domain}'" "*respCostCenter='UM-30001234X'" "*pricePerGBPerYear='0.062'")

    # Manage access
    ichmod -r own "p.suppers@${domain}" /nlmumc/projects/${project}

    # Contributor access
    ichmod -r write rit-l /nlmumc/projects/${project}

    # Viewer access
done

##########
## Special


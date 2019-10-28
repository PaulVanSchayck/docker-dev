#!/usr/bin/env bash

############
## Resources

# Create coordination- and child-resources for project data
iadmin mkresc AZM-storage unixfilesystem ${HOSTNAME}:/mnt/AZM-storage
iadmin mkresc AZM-storage-repl unixfilesystem ${HOSTNAME}:/mnt/AZM-storage-repl
iadmin mkresc replRescAZM01 replication
iadmin addchildtoresc replRescAZM01 AZM-storage
iadmin addchildtoresc replRescAZM01 AZM-storage-repl

# Add comment to resource for better identification in pacman's createProject dropdown
iadmin modresc ${HOSTNAME}Resource comment CENTOS-INGEST-RESOURCE
iadmin modresc replRescAZM01 comment Replicated-resource-for-AZM

# Add storage pricing to resources
imeta add -R ${HOSTNAME}Resource NCIT:C88193 999
imeta add -R replRescAZM01 NCIT:C88193 0

###########
## Projects and project permissions
domain="maastrichtuniversity.nl"

for i in {01..2}; do
    PROJECTNAME=$(fortune | head -n 1 | sed 's/\x27/ /g')
    project=$(irule -F /rules/projects/createProject.r "*authorizationPeriodEndDate='1-1-2018'" "*dataRetentionPeriodEndDate='1-1-2018'" "*ingestResource='${HOSTNAME}Resource'" "*resource='replRescAZM01'" "*storageQuotaGb='10'" "*title='(azM) ${PROJECTNAME}'" "*principalInvestigator='m.coonen@${domain}'" "*respCostCenter='AZM-123456'")

    # Manage access
    ichmod -r own "m.coonen@${domain}" /nlmumc/projects/${project}

    # Contributor access
    ichmod -r write rit-l /nlmumc/projects/${project}

    # Viewer access
done

##########
## Special

imeta set -R replRescAZM01 irods::storage_tiering::group example_group 1
imeta add -R replRescAZM01 irods::storage_tiering::group undo_group 0
imeta set -R replRescAZM01 irods::storage_tiering::time 9999999999
imeta add -R replRescAZM01 irods::storage_tiering::verification checksum

iadmin asq "SELECT R_DATA_MAIN.data_name, R_COLL_MAIN.coll_name, R_DATA_MAIN.data_owner_name, R_DATA_MAIN.data_repl_num  from  R_DATA_MAIN,  R_COLL_MAIN WHERE R_DATA_MAIN.data_owner_name = 'rods'AND R_DATA_MAIN.coll_id = R_COLL_MAIN.coll_id AND R_COLL_MAIN.coll_name LIKE ANY (SELECT concat(R_COLL_MAIN.coll_name,'/%') from R_OBJT_METAMAP, R_COLL_MAIN, R_META_MAIN WHERE R_META_MAIN.meta_attr_name= 'tiering' AND R_COLL_MAIN.coll_id = R_OBJT_METAMAP.object_id AND R_OBJT_METAMAP.meta_id = R_META_MAIN.meta_id) " archive_query
imeta set -R replRescAZM01 irods::storage_tiering::query archive_query specific

icd /nlmumc/projects/P000000012
imkdir C000000001


iput -R replRescUM01 /rules/tests/README.md /nlmumc/projects/P000000010/C000000001
iput -R replRescUM01 /rules/tests/README.md /nlmumc/projects/P000000011/C000000001
iput -R replRescUM01 /rules/tests/README.md /nlmumc/projects/P000000012/C000000001

#!/usr/bin/env bash

############
## Resources

# Create coordination- and child-resources for project data
iadmin mkresc UM-hnas-4k unixfilesystem ${HOSTNAME}:/mnt/UM-hnas-4k
iadmin mkresc UM-hnas-4k-repl unixfilesystem ${HOSTNAME}:/mnt/UM-hnas-4k-repl
iadmin mkresc replRescUM01 replication
iadmin addchildtoresc replRescUM01 UM-hnas-4k
iadmin addchildtoresc replRescUM01 UM-hnas-4k-repl

# Add comment to resource for better identification in pacman's createProject dropdown
iadmin modresc ${HOSTNAME}Resource comment UBUNTU-INGEST-RESOURCE
iadmin modresc replRescUM01 comment Replicated-resource-for-UM

# Add storage pricing to resources
imeta add -R ${HOSTNAME}Resource NCIT:C88193 999
imeta add -R replRescUM01 NCIT:C88193 0.189

###########
## Projects and project permissions
domain="maastrichtuniversity.nl"

for i in {01..2}; do
    PROJECTNAME=$(fortune | head -n 1 | sed 's/\x27/ /g')
    project=$(irule -F /rules/projects/createProject.r "*authorizationPeriodEndDate='1-1-2018'" "*dataRetentionPeriodEndDate='1-1-2018'" "*ingestResource='${HOSTNAME}Resource'" "*resource='replRescUM01'" "*storageQuotaGb='10'" "*title='${PROJECTNAME}'" "*principalInvestigator='p.vanschayck@${domain}'" "*respCostCenter='UM-30001234X'")

    # Manage access
    ichmod -r own "p.vanschayck@${domain}" /nlmumc/projects/${project}

    # Contributor access
    ichmod -r write nanoscopy-l /nlmumc/projects/${project}

    # Viewer access
done

for i in {01..2}; do
    PROJECTNAME=$(fortune | head -n 1 | sed 's/\x27/ /g')
    project=$(irule -F /rules/projects/createProject.r "*authorizationPeriodEndDate='1-1-2018'" "*dataRetentionPeriodEndDate='1-1-2018'" "*ingestResource='${HOSTNAME}Resource'" "*resource='replRescUM01'" "*storageQuotaGb='10'" "*title='${PROJECTNAME}'" "*principalInvestigator='p.suppers@${domain}'" "*respCostCenter='UM-30009998X'")

    # Manage access
    ichmod -r own "p.suppers@${domain}" /nlmumc/projects/${project}

    # Contributor access
    ichmod -r write rit-l /nlmumc/projects/${project}

    # Viewer access
done

for i in {01..1}; do
    PROJECTNAME=$(fortune | head -n 1 | sed 's/\x27/ /g')
    project=$(irule -F /rules/projects/createProject.r "*authorizationPeriodEndDate='1-1-2018'" "*dataRetentionPeriodEndDate='1-1-2018'" "*ingestResource='${HOSTNAME}Resource'" "*resource='replRescUM01'" "*storageQuotaGb='10'" "*title='(ScaNxs) ${PROJECTNAME}'" "*principalInvestigator='m.coonen@${domain}'" "*respCostCenter='UM-30009999X'")

    # Manage access
    ichmod -r own "m.coonen@${domain}" /nlmumc/projects/${project}

    # Contributor access
    ichmod -r write UM-SCANNEXUS /nlmumc/projects/${project}

    # Viewer access
    ichmod -r read rit-l /nlmumc/projects/${project}
done

##########
## Special
imeta set -R replRescUM01 irods::storage_tiering::group example_group 0
imeta add -R replRescUM01 irods::storage_tiering::group undo_group 1
imeta set -R replRescUM01 irods::storage_tiering::time 9999999999
imeta add -R replRescUM01 irods::storage_tiering::verification checksum

iadmin asq "SELECT R_DATA_MAIN.data_name, R_COLL_MAIN.coll_name, R_DATA_MAIN.data_owner_name, R_DATA_MAIN.data_repl_num  from  R_DATA_MAIN,  R_COLL_MAIN WHERE R_DATA_MAIN.data_owner_name = 'rods'AND R_DATA_MAIN.coll_id = R_COLL_MAIN.coll_id AND R_COLL_MAIN.coll_name LIKE ANY (SELECT concat(R_COLL_MAIN.coll_name,'/%') from R_OBJT_METAMAP, R_COLL_MAIN, R_META_MAIN WHERE R_META_MAIN.meta_attr_name= 'tiering' AND R_COLL_MAIN.coll_id = R_OBJT_METAMAP.object_id AND R_OBJT_METAMAP.meta_id = R_META_MAIN.meta_id) " archive_query
imeta set -R replRescUM01 irods::storage_tiering::query archive_query specific


#!/bin/bash

SUFFIX=$1

SCHEMAS='atlas_public_transport atlas_fmd_wrapper atlas_app atlas_registry'

for schema in $SCHEMAS ; do
  ./get_migrations.sh $schema $SUFFIX
done


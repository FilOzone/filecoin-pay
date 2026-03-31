#!/bin/bash

# retry tools/profile.sh until it succeeds


until ./tools/profile.sh ; do {} ; done

#!/bin/bash
rm -Rf vendor-cookbooks *.lock
berks vendor vendor-cookbooks

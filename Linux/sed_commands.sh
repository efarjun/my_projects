find . -type f -exec sed -i 's/demant/birdsong/g' {} +

# .: Tells find to start in the current directory.
# -type f: Ensures the command only runs on files, not directory names (which would cause errors).
# {} +: A placeholder that passes the list of found files to sed in batches for better performance. 


sed '/^$/d' file.txt

# Deletes empty lines.

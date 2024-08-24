export STORAGE_LOCATION=$AIHOME/Documents 
mkdir -p $STORAGE_LOCATION
touch "$STORAGE_LOCATION/.env" 

docker run -d -p 3001:3001 --cap-add SYS_ADMIN \
   --name anythingllm \
   -v ${STORAGE_LOCATION}:/app/server/storage \
   -v ${STORAGE_LOCATION}/.env:/app/server/.env \
   -e STORAGE_DIR="/app/server/storage" mintplexlabs/anythingllm

FROM 710264925055.dkr.ecr.ap-south-1.amazonaws.com/base-images:trion-ng-cli-latest-amd64 As builder

USER root

# RUN apt-get update && apt-get install -y chromium
RUN mkdir  /usr/src/app

WORKDIR /usr/src/app
#RUN ng update @angular/cli @angular/core


COPY package.json  ./

RUN npm cache clean --force

RUN npm install 
RUN npm uninstall angular-tag-cloud-module
RUN npm install --save angular-tag-cloud-module@5.0.0

COPY . .
# RUN npm run test
RUN chmod 777 /usr/src/app

# ENV CHROME_BIN=/usr/bin/chromium
# RUN ng test --no-watch --code-coverage
# RUN ng build --configuration production --base-href   /qiplatform/ --deploy-url /qiplatform/ 
#RUN node --max_old_space_size=4096 && ng build --prod --base-href   /qiplatform/ --deploy-url /qiplatform/
# RUN node --max_old_space_size=4096 node_modules/@angular/cli/bin/ng build --prod --base-href   /qiplatform/ --deploy-url /qiplatform/
RUN node --max_old_space_size=4096 node_modules/@angular/cli/bin/ng build  --configuration production --base-href   /qiplatform/ --deploy-url /qiplatform/
FROM 710264925055.dkr.ecr.ap-south-1.amazonaws.com/base-images:nginx-1.15.8-alpine

RUN mkdir -p /etc/nginx/html/qiplatform

COPY --from=builder /usr/src/app/dist/* /etc/nginx/html

COPY --from=builder /usr/src/app/dist/* /etc/nginx/html/qiplatform

COPY nginx.conf /etc/nginx/nginx.conf

ENTRYPOINT ["nginx", "-g", "daemon off;"]

# CMD ["/bin/sh",  "-c",  "envsubst < /etc/nginx/html/qiplatform/assets/env.template.js > /etc/nginx/html/qiplatform/assets/env.js && exec nginx -g 'daemon off;'"]
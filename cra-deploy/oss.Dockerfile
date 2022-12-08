FROM node:14-alpine as builder

ARG ACCESS_KEY_ID
ARG ACCESS_KEY_SECRET
ARG BUCKET
ARG REGION
ENV PUBLIC_URL https://blog-1255502973.cos.ap-shanghai.myqcloud.com/

WORKDIR /code

RUN pip install coscmd \
    && coscmd config -a $ACCESS_KEY_ID -s $ACCESS_KEY_SECRET -b $BUCKET -r $REGION

# 单独分离 package.json，是为了安装依赖可最大限度利用缓存
ADD package.json yarn.lock /code/
RUN yarn

ADD . /code
RUN npm run build && npm run oss:cli

# 选择更小体积的基础镜像
FROM nginx:alpine
ADD nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder code/build /usr/share/nginx/html
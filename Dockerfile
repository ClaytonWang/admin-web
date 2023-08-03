# 设置基础镜像,基于node:14.0.0版本
FROM vuejs/ci AS frontend-builder

# 配置环境变量
ENV NODE_ENV production

# 创建工作目录
RUN mkdir -p /usr/src/app

# 指定工作目录
WORKDIR /usr/src/app

COPY package.json /usr/src/app/package.json

RUN npm install

# 拷贝所有文件到工作目录
COPY . /usr/src/app

RUN npm run build:prod


FROM nginx:alpine

COPY --from=frontend-builder /usr/src/app/dist /usr/share/nginx/html

COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

ENTRYPOINT ["nginx", "-g", "daemon off;"]

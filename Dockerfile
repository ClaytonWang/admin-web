# 设置基础镜像,基于node:14.0.0版本
FROM vuejs/ci AS frontend-builder

# 创建工作目录
RUN mkdir -p /app

# 指定工作目录
WORKDIR /app

COPY package*.json ./
RUN npm install

# 拷贝所有文件到工作目录
COPY . .

RUN npm run build:prod


FROM nginx:alpine

COPY --from=frontend-builder /usr/src/app/dist /usr/share/nginx/html

COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]

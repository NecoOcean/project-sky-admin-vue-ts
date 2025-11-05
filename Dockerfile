# 第一阶段：构建阶段
FROM node:16-alpine as build-stage

# 安装构建依赖
RUN apk add --no-cache python3 make g++

# 设置工作目录
WORKDIR /app

# 复制 package.json
COPY package.json ./

# 配置 npm 并安装依赖
RUN npm config set strict-ssl false && \
    npm config set registry https://registry.npmmirror.com && \
    npm install --legacy-peer-deps

# 复制项目文件
COPY . .

# 构建项目
RUN npm run build

# 第二阶段：生产阶段
FROM nginx:alpine as production-stage

# 复制自定义nginx配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 从构建阶段复制构建产物
COPY --from=build-stage /app/dist /usr/share/nginx/html

# 暴露80端口
EXPOSE 80

# 启动nginx
CMD ["nginx", "-g", "daemon off;"]
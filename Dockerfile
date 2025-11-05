# 第一阶段：构建阶段
FROM node:16-alpine as build-stage

# 设置工作目录
WORKDIR /app

# 复制package.json和package-lock.json
COPY package*.json ./

# 清理 npm 缓存并安装依赖
RUN npm cache clean --force && \
    npm install --registry=https://registry.npmmirror.com --legacy-peer-deps --omit=optional

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
# Используем базовый образ с Node.js
FROM node:18-alpine

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем package.json и package-lock.json
COPY package*.json ./

# Устанавливаем зависимости
RUN npm install

# Копируем все остальные файлы приложения
COPY . .

# Указываем порт для запуска приложения (при необходимости)
EXPOSE 3000

# Указываем команду для запуска приложения
CMD ["npm", "start"]
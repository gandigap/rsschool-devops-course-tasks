# Используем базовый образ с Node.js
FROM node:16

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем package.json и package-lock.json из js-app в контейнер
COPY js-app/package*.json ./

# Устанавливаем зависимости
RUN npm install

# Копируем все остальные файлы приложения
COPY js-app/ ./

# Указываем команду для запуска приложения
CMD ["npm", "start"]
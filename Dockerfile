FROM public.ecr.aws/nginx/nginx:stable-alpine
COPY html /usr/share/nginx/html

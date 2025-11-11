FROM atmoz/sftp:latest

CMD [ "default:1234:1000:1000" ]
RUN chown -R default:default /home/default
FROM clfoundation/sbcl:latest
WORKDIR /app
RUN curl -O https://beta.quicklisp.org/quicklisp.lisp && \
    sbcl --load quicklisp.lisp --eval "(quicklisp-quickstart:install)" --quit && \
    echo '#-quicklisp(load "~/quicklisp/setup.lisp")' >> ~/.sbclrc
RUN sbcl --eval "(ql:quickload :hunchentoot)" --eval "(ql:quickload :cl-json)" --quit
COPY *.lisp .
EXPOSE 8081
CMD ["sbcl", "--load", "verdict-server.lisp"]

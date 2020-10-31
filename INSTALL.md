# REBlog Installation Guide

REBlog has only been tested with REBOL/Core 2.5.6 under Linux.

## How to Install REBlog

  1. Create a data directory for REBlog.
  1. Within the data directory, create a directory called `posts`.
  1. Make both directories readable for REBlog (e.g. the web server user).
  1. Within reblog.r, configure the `data-dir` variable. Fill in the directory from the first step.
  1. Move reblog.r to the cgi-bin of your web server.
  1. Check if reblog.r is executable. `chmod 0755` if necessary.

## The `authors` File

Optionally, you may create a file called `authors` within the data directory. Each line within that file will define an author by nickname, full name, e-mail address and website. The fields are seperated using `"`.

> rbrt-weiler"Robert Weiler"nicetry@example.com"https://gitlab.com/rbrt-weiler/

REBlog will work without an `authors` file.

## Writing a New Post

Just drop a file within the `posts` folder. The format is as follows:

- The first line is the author nickname.
- The second line is the post title.
- Everything else is the post itself.

It is not required to define the author in the `authors` file.

By default, the post title will be enclosed with h2 tags and the post itself will be enclosed by p tags.

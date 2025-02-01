---
date: '{{ .Date }}'
tags:
- notag
draft: true
title: '{{ replace .File.ContentBaseName "-" " " | title }}'
---

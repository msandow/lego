module.exports =
  port: 3333
  cleanHTML: (str) ->
    str.replace(/(\n|\t|\s{2,})/g ,'')
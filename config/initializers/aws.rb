AWS.config({
    :access_key_id => Figaro.env.access_key_id,
    :secret_access_key => Figaro.env.secret_access_key
  })
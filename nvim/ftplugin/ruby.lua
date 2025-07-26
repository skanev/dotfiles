require("config.ft").once {
  tabs = 2,
  runner = {
    {
      when = '_spec\\.rb$',
      file = 'rspec --format=documentation {file}',
      line = 'rspec --format=documentation {file}:{line}'
    },
  }
}

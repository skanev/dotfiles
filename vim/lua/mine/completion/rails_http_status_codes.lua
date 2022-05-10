local u = require('mine.util')

local codes = {
  { ':continue' , '100 Continue' },
  { ':switching_protocols' , '101 Switching Protocols' },
  { ':processing' , '102 Processing' },
  { ':early_hints' , '103 Early Hints' },
  { ':ok' , '200 OK' },
  { ':created' , '201 Created' },
  { ':accepted' , '202 Accepted' },
  { ':non_authoritative_information' , '203 Non-Authoritative Information' },
  { ':no_content' , '204 No Content' },
  { ':reset_content' , '205 Reset Content' },
  { ':partial_content' , '206 Partial Content' },
  { ':multi_status' , '207 Multi-Status' },
  { ':already_reported' , '208 Already Reported' },
  { ':im_used' , '226 IM Used' },
  { ':multiple_choices' , '300 Multiple Choices' },
  { ':moved_permanently' , '301 Moved Permanently' },
  { ':found' , '302 Found' },
  { ':see_other' , '303 See Other' },
  { ':not_modified' , '304 Not Modified' },
  { ':use_proxy' , '305 Use Proxy' },
  { ':temporary_redirect' , '307 Temporary Redirect' },
  { ':permanent_redirect' , '308 Permanent Redirect' },
  { ':bad_request' , '400 Bad Request' },
  { ':unauthorized' , '401 Unauthorized' },
  { ':payment_required' , '402 Payment Required' },
  { ':forbidden' , '403 Forbidden' },
  { ':not_found' , '404 Not Found' },
  { ':method_not_allowed' , '405 Method Not Allowed' },
  { ':not_acceptable' , '406 Not Acceptable' },
  { ':proxy_authentication_required' , '407 Proxy Authentication Required' },
  { ':request_timeout' , '408 Request Timeout' },
  { ':conflict' , '409 Conflict' },
  { ':gone' , '410 Gone' },
  { ':length_required' , '411 Length Required' },
  { ':precondition_failed' , '412 Precondition Failed' },
  { ':payload_too_large' , '413 Payload Too Large' },
  { ':uri_too_long' , '414 URI Too Long' },
  { ':unsupported_media_type' , '415 Unsupported Media Type' },
  { ':range_not_satisfiable' , '416 Range Not Satisfiable' },
  { ':expectation_failed' , '417 Expectation Failed' },
  { ':misdirected_request' , '421 Misdirected Request' },
  { ':unprocessable_entity' , '422 Unprocessable Entity' },
  { ':locked' , '423 Locked' },
  { ':failed_dependency' , '424 Failed Dependency' },
  { ':too_early' , '425 Too Early' },
  { ':upgrade_required' , '426 Upgrade Required' },
  { ':precondition_required' , '428 Precondition Required' },
  { ':too_many_requests' , '429 Too Many Requests' },
  { ':request_header_fields_too_large' , '431 Request Header Fields Too Large' },
  { ':unavailable_for_legal_reasons' , '451 Unavailable for Legal Reasons' },
  { ':internal_server_error' , '500 Internal Server Error' },
  { ':not_implemented' , '501 Not Implemented' },
  { ':bad_gateway' , '502 Bad Gateway' },
  { ':service_unavailable' , '503 Service Unavailable' },
  { ':gateway_timeout' , '504 Gateway Timeout' },
  { ':http_version_not_supported' , '505 HTTP Version Not Supported' },
  { ':variant_also_negotiates' , '506 Variant Also Negotiates' },
  { ':insufficient_storage' , '507 Insufficient Storage' },
  { ':loop_detected' , '508 Loop Detected' },
  { ':bandwidth_limit_exceeded' , '509 Bandwidth Limit Exceeded' },
  { ':not_extended' , '510 Not Extended' },
  { ':network_authentication_required' , '511 Network Authentication Required' },
}

local entries = u.map(codes, function(item)
  return {
    label = item[1],
    labelDetails = { description = item[2] },
    kind = require('cmp.types.lsp').CompletionItemKind.Enum,
  }
end)

local source = {}

function source.new(client)
  local self = setmetatable({}, { __index = source })
  self.client = client
  self.request_ids = {}
  return self
end

--function source:is_available()
  --return vim.b.rails_cached_file_type == 'controller'
--end

function source:get_debug_name()
  return 'rails_http_status_codes'
end

function source:get_keyword_pattern()
  return [[:\k\+]]
end

function source:get_trigger_characters()
  return { ':' }
end

function source:complete(params, callback)
  print("HI")
  if vim.fn.match(params.context.cursor_before_line, [[\s*render .*\<status: \+:\k*$]]) >= 0 then
    callback(entries)
  else
    callback({})
  end
end

function source:resolve(completion_item, callback)
  callback(completion_item)
end

function source:execute(completion_item, callback)
  callback(completion_item)
end

require('mine.completion.util').establish_source('rails_http_status_codes', source.new())

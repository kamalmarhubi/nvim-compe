local Pattern = require'compe.pattern'

local Source = {}

function Source.new(client)
  local self = setmetatable({}, { __index = Source })
  self.client = client
  return self
end

function Source:get_metadata()
  return {
    priority = 1000;
    dup = 0;
    menu = '[LSP]';
  }
end

function Source:datermine(context)
  local trigger_chars = (function()
    if not self.client.server_capabilities then
      return {}
    end
    if not self.client.server_capabilities then
      return {}
    end
    if not self.client.server_capabilities.completionProvider then
      return {}
    end
    if not self.client.server_capabilities.completionProvider.triggerCharacters then
      return {}
    end
    return self.client.server_capabilities.completionProvider.triggerCharacters
  end)()

  if vim.tbl_contains(trigger_chars, context.before_char) and context.before_char ~= ' ' then
    return {
      keyword_pattern_offset = Pattern:get_keyword_pattern_offset(context);
      trigger_character_offset = context.col;
    }
  end

  return {
    keyword_pattern_offset = Pattern:get_keyword_pattern_offset(context)
  }
end

function Source:complete(args)
  local params = vim.lsp.util.make_position_params()

  if vim.lsp.client_is_stopped(self.client.id) then
    return args.abort()
  end

  params.context = {
    triggerKind = (args.trigger_character_offset > 0 and 2 or (args.incomplete and 3 or 1))
  }

  if args.trigger_character_offset > 0 then
    params.context.triggerCharacter = args.context.before_char
  end

  self.client.request('textDocument/completion', params, function(err, _, result)
    if err or not result then return args.abort() end
    args.callback({
      items = vim.lsp.util.text_document_completion_list_to_complete_items(result, '');
      incomplete = result.incomplete or false;
    })
  end)
end

function Source:convert(response)
end

return Source

local skeleton = require 'nvim_lsp/skeleton'
local util = require 'nvim_lsp/util'
local lsp = vim.lsp

local cwd = vim.loop.cwd()

local texlab_build_status = vim.tbl_add_reverse_lookup {
  Success = 0;
  Error = 1;
  Failure = 2;
  Cancelled = 3;
}

local function buf_build(bufnr)
  bufnr = util.validate_bufnr(bufnr)
  local params = { textDocument = { uri = vim.uri_from_bufnr(bufnr) }  }
  lsp.buf_request(bufnr, 'textDocument/build', params,
      function(err, _, result, _)
        if err then error(tostring(err)) end
        print("Build "..texlab_build_status[result.status])
      end)
end

-- bufnr isn't actually required here, but we need a valid buffer in order to
-- be able to find the client for buf_request.
-- TODO find a client by looking through buffers for a valid client?
local function build_cancel_all(bufnr)
  bufnr = util.validate_bufnr(bufnr)
  local params = { token = "texlab-build-*" }
  lsp.buf_request(bufnr, 'window/progress/cancel', params, function(err, method, result, client_id)
    if err then error(tostring(err)) end
    print("Cancel result", vim.inspect(result))
  end)
end

skeleton.texlab = {
  default_config = {
    cmd = {"texlab"};
    filetypes = {"tex", "bib"};
    root_dir = function() return cwd end;
    log_level = lsp.protocol.MessageType.Warning;
    settings = {
      latex = {
        build = {
          args = {"-pdf", "-interaction=nonstopmode", "-synctex=1"};
          executable = "latexmk";
          onSave = false;
        };
      };
    };
  };
  commands = {
    TexlabBuild = {
      function()
        buf_build(0)
      end;
      description = "Build the current buffer";
    };
    -- TexlabCancelAllBuilds = {
    -- };
  };
  -- on_new_config = function(new_config) end;
  -- on_attach = function(client, bufnr) end;
  docs = {
    description = [[
https://texlab.netlify.com/

A completion engine built from scratch for (la)tex.
]];
    default_config = {
      root_dir = "vim's starting directory";
    };
  };
}

skeleton.texlab.buf_build = buf_build
-- vim:et ts=2 sw=2

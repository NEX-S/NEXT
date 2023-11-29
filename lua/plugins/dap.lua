return {
    {  "mfussenegger/nvim-dap",
        -- event = "BufEnter",
        dependencies = {
            {
                "rcarriga/nvim-dap-ui",
                config = function ()
                    require "dapui".setup()
                end
            }, {
                "theHamsta/nvim-dap-virtual-text",
                config = function ()
                    require "nvim-dap-virtual-text".setup()
                end
            }
        },
        config = function()
            local dap = require "dap"

            dap.adapters.codelldb = {
                type = 'server',
                port = "${port}",
                executable = {
                    command = 'codelldb',
                    args = {"--port", "${port}"},
                }
            }

            dap.configurations.c = {
                {
                    name = "Launch file",
                    type = "codelldb",
                    request = "launch",
                    program = function()
                        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                    end,
                    cwd = '${workspaceFolder}',
                    args = {
                        "/var/www/nginx/include.php",
                    },
                    stopOnEntry = false,
                },
            }
        end
    }
}

require('vis')
require('plugins/filetype')
require('vis-ctags')

vis.ftdetect.filetypes["terraform"] = {
	ext = { "%.tf$", "%.tfvars$" },
}

settings = {
	go         = { 'set expandtab off', 'set tabwidth 8' };
	c          = { 'set expandtab off', 'set tabwidth 8' };
	cpp        = { 'set expandtab on', 'set tabwidth 4' };
	python	   = { 'set expandtab on', 'set tabwidth 4' };
	markdown   = { 'set expandtab on', 'set tabwidth 2' };
	java	   = { 'set expandtab on', 'set tabwidth 2' };
	javascript = { 'set expandtab on', 'set tabwidth 2' };
	json	   = { 'set expandtab on', 'set tabwidth 2' };
	terraform  = { 'set expandtab on', 'set tabwidth 2' };
};

-- open files with fzf. fixed from git.sr.ht/~mcepl/vis-fzf-open
vis:command_register("fzf", function(argv, force, win, selection, range)
	local command = string.gsub([[
		$fzf_path \
			--header="Enter:edit,^s:split,^v:vsplit" \
			--expect="ctrl-s,ctrl-v" \
			$fzf_args $args
		]],
		'%$([%w_]+)', {
			fzf_path="fzf",
			fzf_args="",
			args=table.concat(argv, " ")
		}
	)
	local file = io.popen(command)
	local output = {}
	for line in file:lines() do
		table.insert(output, line)
	end
	local success, msg, status = file:close()
	if status == 0 then
		local action = ':e'

		if	 output[1] == 'ctrl-s' then action = ':split'
		elseif output[1] == 'ctrl-v' then action = ':vsplit'
		end

		vis:feedkeys(string.format("%s '%s'<Enter>", action, output[2]))
	end
	vis:feedkeys("<vis-redraw>")
	return true;
end, "Select file to open with fzf")


vis:command_register("gitblame", function(argv, force, win, selection, range)
	local curline = win.selection.line
	local target = win.file.path
	local tmpfile = '/tmp/blamefile'
	local action = ':split'

	os.execute(string.format("git blame %s > %s", target, tmpfile))
	vis:feedkeys(string.format("%s %s<Enter>", action, tmpfile))
	vis:feedkeys(string.format(":%d<Enter>", curline))

	return true;
end)

vis.events.subscribe(vis.events.INIT, function()

	-- global configuration
	vis:command('set theme dark-16') -- use terminal theme
	vis:command('set escdelay 10')   -- interpret escape properly
	vis:command('set shell /usr/bin/bash')   -- interpret escape properly


	vis:map(vis.modes.NORMAL, '<C-c>', '<Escape>')

	-- keyboard shortcuts
	vis:command('map! normal <C-p> :fzf<Enter>')
	vis:command('map! normal S :w!<Enter>')
	vis:command('map! normal X :!')
	vis:command('map! normal ; :')
	vis:command('map normal Q :q!<Enter>')

	-- shell interaction
	---- quickly edit visrc
	vis:map(vis.modes.NORMAL, 've', ':sp ~/.config/vis/visrc.lua<Enter>')
	---- generate tags
	vis:map(vis.modes.NORMAL, ' ct', ':!ctags -R .<Enter>')

	---- git
	vis:map(vis.modes.NORMAL, 'ga', ':!git add ')
	vis:map(vis.modes.NORMAL, 'gA', ':!git add -A<Enter>')
	vis:map(vis.modes.NORMAL, 'gd', ':!git diff | less<Enter>')
	vis:map(vis.modes.NORMAL, 'gl', ':!git log | less<Enter>')
	vis:map(vis.modes.NORMAL, 'gb', ':gitblame<Enter>')
	vis:map(vis.modes.NORMAL, 'gc', ':!git commit -am \'')
	vis:map(vis.modes.NORMAL, 'gp', ':!git pull ')
	vis:map(vis.modes.NORMAL, 'gP', ':!git push<Enter>')
	vis:map(vis.modes.NORMAL, 
		'gs', 
		':!git status >/tmp/statout<Enter>:sp /tmp/statout<Enter>')

	-- clipboard interaction
	vis:map(vis.modes.VISUAL, ' y', '"+y')
	vis:map(vis.modes.NORMAL, ' p', '"+p')
end)

vis.events.subscribe(vis.events.WIN_OPEN, function(win)

	-- process filetype settings (requires syntax to be on)
	if settings == nil then return end
	local window_settings = settings[win.syntax]
	if type(window_settings) == "table" then
		for _, setting in pairs(window_settings) do
			vis:command(setting)
		end
	elseif type(window_settings) == "function" then
		window_settings(win)
	else
		vis:command('set expandtab off')
		vis:command('set tabwidth 8')
	end

	-- general editing
	vis:command('set autoindent on')

	-- searching / replacement
	vis:command('set ignorecase on')

	-- visual settings
	vis:command('set syntax off')


	---- comment lines
	vis:map(vis.modes.VISUAL_LINE, ' ;', 
		string.format(":|com -f %s<Enter>", win.file.name))

	---- prettier
	vis:map(vis.modes.NORMAL, ' fP', 
		string.format(
			":0,$|prettier --print-width 80 --prose-wrap always %s<Enter>", 
			win.file.name))

	---- go
	------ formatting
	vis:map(vis.modes.NORMAL, ' gf', 
		string.format(
			":0,$|gofmt %s<Enter>", 
			win.file.name))
	------ testing
	vis:map(vis.modes.NORMAL, ' gt', 
		string.format('%s && %s<Enter>%s<Enter>',
 			-- change to containing directory
			string.format(':!cd $(dirname %s)', win.file.path),
			-- run all tests
			'go test -race -bench Benchmark* -count=1 >/tmp/testout 2>&1',
			-- preview the output
			':split /tmp/testout'
		)
	)

	-- make
	vis:map(vis.modes.NORMAL, ' m', ':!make ')

	-- terraform
	vis:map(vis.modes.NORMAL, ' tv', ':!terraform validate<Enter>')
	vis:map(vis.modes.NORMAL, ' tp', ':!terraform plan<Enter>')
	vis:map(vis.modes.NORMAL, ' ta', ':!terraform apply<Enter>')
	vis:map(vis.modes.NORMAL, ' tf', ':w<Enter>:!terraform fmt<Enter>:e!<Enter>')

end)


gColor = {
    ['red'] =    hex('#ff0000'),
	['orange'] = hex('#ff9700'),
	['yellow'] = hex('#fffe00'),
	['limey'] =  hex('#0cff00'),
	['bluey'] =  hex('#007bff'),
    ['white'] =  hex('#ffffff'),
    ['black'] =  hex('#000000'),

}

-- Self references
local c = gColor

c['BindingSite:bound'] = c['bluey']
c['BindingSite:ready'] = c['limey']
c['BindingSite:sleep'] = c['orange']

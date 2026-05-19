Wolfy = {}

Wolfy.ResourceAllowed = { -- List of resources that are allowed to use the exports
    ['esx_society'] = true,
    ['esx_advancedgarage'] = true
}

Wolfy.Command = {
    ['banpanel'] = {
        command = 'wpanel',
        groups = {
            'owner'
        }
    }
    ,
    ['ban'] = {
        command = 'wban',
        groups = {
            'owner'
        }
    },

    ['unban'] = {
        command = 'wub',
        groups = {
            'owner'
        }
    }
}
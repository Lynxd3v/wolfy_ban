let banList = [
    {
        name: 'John Doe',
        time: '2025-05-22'
    },
    {
        name: 'Jane Smith',
        time: '2024-12-01'
    }
]

let selectedBan = null

function renderBanList(List) {
    const container = document.getElementById('banList')

    container.innerHTML = ''

    if (List.length === 0) {
        const container = document.getElementById('banList')
        container.innerHTML = '<p class="text-zinc-400 mt-5 text-[0.85vw]">Nincsen unban</p>'
        return
    }


    for (let i = 0; i < List.length; i++) {

        const item = List[i]
        const div = document.createElement('div')
        div.classList.add('w-[85%]', 'flex', 'items-center', 'gap-3', 'bg-zinc-700', 'hover:bg-zinc-600', 'border', 'border-white/5', 'rounded-lg', 'px-3', 'py-2', 'cursor-pointer', 'transition-colors')
        div.innerHTML = `<div class="w-9 h-9 rounded-full bg-purple-900 flex items-center justify-center text-purple-200 text-xs font-medium flex-shrink-0" ></div>
                    <div class="flex-1 min-w-0">
                        <p class="text-[0.85vw] font-medium text-white truncate m-0 select-none">${item.name}</p>
                        <p class="text-[0.65vw] text-zinc-400 m-0 select-none">Lejár: ${item.time === 0 ? 'Soha' : item.time}</p>
                    </div>
                    <span class="select-none text-[0.6vw] px-2 py-0.5 rounded-full ${item.time === 0 ? 'bg-red-900 text-red-300' : 'bg-green-900 text-green-300'}">${item.time === 0 ? 'Perm' : 'Temp'}</span>`

        div.addEventListener('click', function () {
            selectBan(item)
            selectedBan = item.banId
        })

        container.appendChild(div)

    }
}

function selectBan(ban) {
    const isPerm = ban.time === 0
    const expire = isPerm ? 'Soha' : new Date(ban.time * 1000).toLocaleString('hu-HU')

    document.getElementById('banName').textContent = ban.name
    document.getElementById('licenseidentifier').textContent = ban.identifier?.license || 'N/A'
    document.getElementById('discordidentifier').textContent = ban.identifier?.discord || 'N/A'
    document.getElementById('ipidentifier').textContent = ban.identifier?.ip || 'N/A'
    document.getElementById('fivemidentifier').textContent = ban.identifier?.fivem || 'N/A'
    document.getElementById('bannedby').textContent = ban.bannedby || 'N/A'
    document.getElementById('banId').textContent = '#' + ban.banId
    document.getElementById('banTime').textContent = expire
    document.getElementById('banReason').textContent = '"' + ban.reason + '"'
}

window.addEventListener('keyup', function (event) {
    if (event.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/closePanel`)
    }
})

window.addEventListener('message', function (event) {
    const e = event.data


    if (e.action === 'showPanel') {
        banList = e.banList
        renderBanList(banList)
        document.body.classList.remove('hidden')
        document.body.classList.add('flex')
    } else if (e.action === 'hidePanel') {
        document.body.classList.add('hidden')
        document.body.classList.remove('flex')
    }
})

document.getElementById('unbanbtn').addEventListener('click', function () {
    if (!selectedBan) return

    fetch(`https://${GetParentResourceName()}/unban`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ banId: selectedBan })
    })
})

document.getElementById('search').addEventListener('input', function (e) {
    const value = e.target.value.toLowerCase()

    if (value === '') {
        renderBanList(banList)
        return
    }

    const filteredList = banList.filter(item => item.name.toLowerCase().includes(value))

    if (filteredList.length === 0) {
        const container = document.getElementById('banList')
        container.innerHTML = '<p class="text-zinc-400 mt-5 text-[0.85vw]">Nincs találat</p>'
        return
    }
    renderBanList(filteredList)
})
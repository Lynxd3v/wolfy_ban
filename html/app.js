function renderBanList(List) {
    const container = document.getElementById('banList')

    container.innerHTML = ''

    if (List.lenght === 0) {
        const div = document.createElement('div')
        return
    }


    for (let i = 0; i < List.lenght; i++) {

        const item = List[i]
        const div = document.createElement('div')
        div.classList.add('w-[85%] flex items-center gap-3 bg-zinc-700 hover:bg-zinc-600 border border-white/5 rounded-lg px-3 py-2 cursor-pointer transition-colors')
        div.innerHTML = `<div
        class="w-9 h-9 rounded-full bg-purple-900 flex items-center justify-center text-purple-200 text-xs font-medium flex-shrink-0" >
                        
                    </div >
                    <div class="flex-1 min-w-0">
                        <p class="text-[0.85vw] font-medium text-white truncate m-0">${item.name}</p>
                        <p class="text-[0.65vw] text-zinc-400 m-0">Lejár: 2025-05-22</p>
                    </div>
                    <span class="text-[0.6vw] px-2 py-0.5 rounded-full bg-green-900 text-green-300">${item.time === 0? 0 : item.time}</span>`

        div.addEventListener('click',function() {
            
        })

        container.append(div)
        
    }

    container.appendChild(div)
}

window.addEventListener('message', function (event) {
    const e = event.data


    if (e.action === 'showPanel') {

    } else if (e.action === 'hidePanel') {

    }
})


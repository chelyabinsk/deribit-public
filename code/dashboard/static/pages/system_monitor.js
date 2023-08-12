document.addEventListener('DOMContentLoaded', function () {
    const fitter_cancel_button = document.getElementById('kill-fitter-btn');
    const fitter_restart_button = document.getElementById('restart-fitter-btn');
    const fitter_status_button = document.getElementById("status-fitter-btn");
    fitter_status_badge = document.getElementById("fitter-status-badge");
    fitter_status_text = document.getElementById("fitter-status-text");
    dashboard_status_badge = document.getElementById("dashboard-status-badge");

    fitter_status_badge.className = "badge text-bg-secondary"
    fitter_status_badge.innerHTML = "Fitter: no status"

    check_fitter_status()
    intervaled_function()
    

    fitter_cancel_button.addEventListener('click', async _ => {
        try {
            const response = await fetch(cancel_fitter_endpoint, {
                method: 'GET',
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json',
                }
            });
            // console.log('Completed!', response);
            fitter_status_badge.className = "badge text-bg-warning"
            fitter_status_badge.innerHTML = "Fitter: Cancelling"
        } catch (err) {
            dashboard_status_badge.className = "badge text-bg-warning"
            dashboard_status_badge.innerHTML = "Dashboard: ${err}"
            console.error(`Error: ${err}`);
        }
    });

    fitter_restart_button.addEventListener('click', async _ => {
        try {
            const response = await fetch(restart_fitter_endpoint, {
                method: 'GET',
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json',
                }
            });
            // console.log('Completed!', response);
            fitter_status_badge.className = "badge text-bg-warning"
            fitter_status_badge.innerHTML = "Fitter: Restarting"
        } catch (err) {
            dashboard_status_badge.className = "badge text-bg-warning"
            dashboard_status_badge.innerHTML = "Dashboard: ${err}"
            console.error(`Error: ${err}`);
        }
    });

    // fitter_status_button.addEventListener('click', async _ => {
    //     check_fitter_status();
    // });
}
);

async function check_fitter_status() {
    try {
        const response = await fetch(fitter_status_endpoint, {
            method: 'GET',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
            }
        });
        response.json().then(resp => {
            fitter_status_text.innerHTML = resp["response_description_str"]
            if(resp["fitter_status"] == "cancelled"){
                fitter_status_badge.className = "badge text-bg-danger"
                fitter_status_badge.innerHTML = "Fitter: Cancelled"
            }else if(resp["fitter_status"] == "running"){
                fitter_status_badge.className = "badge text-bg-success"
                fitter_status_badge.innerHTML = "Fitter: Running"
            }else if(resp["fitter_status"] == "starting"){
                fitter_status_badge.className = "badge text-bg-warning"
                fitter_status_badge.innerHTML = "Fitter: Starting"
            }
        })
    } catch (err) {
        console.error(`Error: ${err}`);
    }
}

const intervaled_function = () => {
    setInterval(
      function () {
        check_fitter_status()
      },
      30*1000
    );
  
  };
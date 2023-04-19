<script>
  export let routing_number = "123456789"
  export let account_number = "123456789"

  let routing_display
  $: routing_display = routing_number.padStart(9, "0")

  let account_display
  $: account_display = account_number.padStart(12, "0")
</script>

<div class="check-container">
  <svg id="check-svg" viewBox="0 0 512 64">
    <linearGradient id="card_background" gradientUnits="userSpaceOnUse" x1="300" y1="0" x2="512" y2="54"
                    gradientTransform="matrix(1 0 0 -1 -50 30.5186)">
      <stop offset="0" style="stop-color:#eee;"/>
      <stop offset="1" style="stop-color:white"/>
    </linearGradient>

    <path stroke="lightgrey" fill="url(#card_background)"
          d="M 0 8 l 17 -8 l 15 8 l 17 -8 l 15 8 l 17 -8 l 15 8 l 17 -8 l 15 8 l 17 -8 l 15 8 l 17 -8 l 15 8 l 17 -8 l 15 8 l 17 -8 l 15 8 l 17 -8 l 15 8 l 17 -8 l 15 8 l 17 -8 l 15 8 l 17 -8 l 15 8 l 17 -8 l 15 8 l 17 -8 l 15 8 l 17 -8 l 15 8 l 17 -8 l 15 8 l 0 55 l -512 0 z"/>
    <path stroke="#999" fill="none"
          d="M 0 40 m 15 0 l 200 0"/>
    <text x="15" y="53" class="small">{routing_display}</text>
    <text x="105" y="53" class="small">{account_display}</text>
  </svg>
</div>

<style>
  .check-container {
      /* padding: 16px; */
      padding-bottom: 16px;
  }

  .small {
      font: italic 13px sans-serif;
      fill: #999;
  }
</style>

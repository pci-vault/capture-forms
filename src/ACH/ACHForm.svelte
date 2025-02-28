<!--suppress CssUnknownTarget -->
<script>
    import {onMount, tick} from 'svelte';
    import axios from "axios";
    import Keypad from "../lib/Keypad.svelte";
    import Check from "./Check.svelte";

    export let pci_address_prod = "";
    export let pci_address_testing = "";

    export let testing = false
    export let submit_url = ""
    export let submit_secret = ""
    export let success_callback = function () {
    }
    export let error_callback = function () {
    }
    export let extra_data = {}
    export let show_check = true

    export let force_keypad = false

    export let field_options = {}
    let field_settings = {
        routing_number: {
            visible: field_options.routing_number?.visible ?? true,
            validate: field_options.routing_number?.validate ?? true,
        },
        account_number: {
            visible: field_options.account_number?.visible ?? true,
            validate: field_options.account_number?.validate ?? true,
        },
        account_holder: {
            visible: field_options.account_holder?.visible ?? true,
            validate: field_options.account_holder?.validate ?? true,
        },
        account_type: {
            visible: field_options.account_type?.visible ?? true,
            validate: field_options.account_type?.validate ?? true,
        },
    }

    const validate_field = (entry) => field_settings[entry].validate && field_settings[entry].visible

    let validate = false
    let routing_number = ""
    let account_number = ""
    let account_holder = ""

    let account_types = [
        "Individual Savings",
        "Individual Checking",
        "Business Savings",
        "Business Checking",
    ]
    let account_type = account_types[0]

    let result;
    let routing_number_keypad = false;
    let account_number_keypad = false;

    onMount(function () {
        window.addEventListener('load', () => document.getElementById("routing_number").focus())
    })

    $: valid_routing_number = !validate || !validate_field("routing_number") || (routing_number && routing_number.length > 1)
    $: valid_account_number = !validate || !validate_field("account_number") || (account_number && account_number.length > 1)
    $: valid_account_holder = !validate || !validate_field("account_holder") || account_holder
    $: valid_account_type = !validate || !validate_field("account_type") || account_type
    $: allValid = valid_routing_number && valid_account_number && valid_account_holder && valid_account_type

    let pci_address = testing ? pci_address_testing : pci_address_prod

    async function submit() {
        validate = true
        await tick();
        if (!allValid) {
            return
        }

        if (!submit_url || !submit_secret || !submit_url.startsWith("/v1/capture/")) {
            throw new Error("Submit info not set correctly")
        }

        let url = pci_address + submit_url
        let submit_data = {
            ...extra_data,
            "account_number": account_number,
            "routing_number": routing_number,
            "account_type": account_type,
            "account_holder": account_holder,
            "last_four": account_number.slice(-4),
        }
        axios({
            method: 'post',
            'url': url,
            data: submit_data,
            headers: {
                "X-PCIVault-Capture-Secret": submit_secret
            }
        }).then(async function (d) {
            result = "Account successfully captured."
            await tick();
            if (typeof success_callback === 'function') {
                success_callback(d.data, submit_data)
            }
        }).catch(async function (r) {
            result = "An error occurred, refresh the page and try again."
            await tick();
            if (typeof error_callback === 'function') {
                error_callback({code: r.response.status, data: r.response.data}, submit_data)
            }
        })
    }

    let submit_button_width = 300
    let submit_font_size
    $: submit_font_size = Math.round(0.05 * submit_button_width)
</script>

<div id="pcivault-ach-form" class="ach-form">
  <div id="pcivault-ach-form-container" class="ach-form__inner">
    {#if field_settings.routing_number.visible}
      <div id="pcivault-ach-form-routing-number" class="ach-input">
        {#if routing_number_keypad}
          <Keypad bind:number={routing_number} on:close={() => routing_number_keypad = false}/>
        {/if}
        <label id="pcivault-ach-form-routing-number-label" for="routing_number" class="ach-input__label">
          Routing Number
          {#if !valid_routing_number}
            <span id="pcivault-ach-form-routing-number-label-error"
                  class="ach-input__error">{routing_number ? "invalid credit card number" : "required"}</span>
          {/if}
        </label>
        <input type="text" id="routing_number" class="ach-input__input"
               class:ach-input__invalid={!valid_routing_number}
               bind:value={routing_number}
               on:focus={() => routing_number_keypad = force_keypad}
               on:keypress={(e) => {routing_number_keypad && e.preventDefault(); return !routing_number_keypad}}>
      </div>
    {/if}
    {#if field_settings.account_number.visible}
      <div id="pcivault-ach-form-account-number" class="ach-input">
        {#if account_number_keypad}
          <Keypad bind:number={account_number} on:close={() => account_number_keypad = false}/>
        {/if}
        <label id="pcivault-ach-form-account-number-label" for="account_number" class="ach-input__label">
          Account Number
          {#if !valid_account_number}
            <span id="pcivault-ach-form-account-number-label-error"
                  class="ach-input__error">{account_number ? "invalid credit card number" : "required"}</span>
          {/if}
        </label>
        <input type="text" id="account_number" class="ach-input__input"
               class:ach-input__invalid={!valid_account_number}
               bind:value={account_number}
               on:focus={() => account_number_keypad = force_keypad}
               on:keypress={(e) => {account_number_keypad && e.preventDefault(); return !account_number_keypad}}>
      </div>
    {/if}
    {#if show_check}
      <Check account_number={account_number || "123456789"} routing_number={routing_number || "123456789"}/>
    {/if}
    {#if field_settings.account_type.visible}
      <div id="pcivault-ach-form-account-type" class="ach-input">
        <label id="pcivault-ach-form-account-type-error" for="account_type" class="ach-input__label">
          Account Type
          {#if !valid_account_type}
            <span id="pcivault-ach-form-account-type-error-label"
                  class="ach-input__error">{account_type ? "invalid account type" : "required"}</span>
          {/if}
        </label>
        <select id="account_type" class="ach-input__input"
                class:ach-input__invalid={!valid_account_type}
                bind:value={account_type}>
          {#each account_types as at, id}
            <option value={at}>{at}</option>
          {/each}
        </select>
      </div>
    {/if}
    {#if field_settings.account_holder.visible}
      <div id="pcivault-ach-form-account-holder" class="ach-input">
        <label id="pcivault-ach-form-account-holder-label" for="account_holder" class="ach-input__label">
          Account Holder
          {#if !valid_account_holder}
            <span id="pcivault-ach-form-account-holder-label-error" class="ach-input__error">required</span>
          {/if}
        </label>
        <input type="text" id="account_holder" class="ach-input__input" class:ach-input__invalid={!valid_account_holder}
               bind:value={account_holder}>
      </div>
    {/if}

    <button id="pcivault-ach-form-button-submit" class="ach-form__button" on:click={submit}
            disabled='{!allValid || result}' bind:clientWidth={submit_button_width}
            style="font-size:{submit_font_size}px;">
      SECURE CAPTURE ACCOUNT
    </button>
    {#if result}
      <div id="pcivault-ach-form-submit-result"
           class="ach-input__result {result.includes('error') ? 'ach-input__error' : 'ach-input__success'}">
        {result}
      </div>
    {/if}
  </div>
</div>

<style>
    @font-face {
        font-family: "SFProDisplay";
        src: url("/assets/SFProDisplay-Light.woff2");
        font-weight: 300;
    }

    @font-face {
        font-family: "SFProDisplay";
        src: url("/assets/SFProDisplay-Regular.woff2");
        font-weight: normal;
    }

    @font-face {
        font-family: "SFProDisplay";
        src: url("/assets/SFProDisplay-Medium.woff2");
        font-weight: 500;
    }

    @font-face {
        font-family: "SFProDisplay";
        src: url("/assets/SFProDisplay-Bold.woff2");
        font-weight: bold;
    }

    * {
        box-sizing: border-box;
    }

    *:focus {
        outline: none;
    }

    .ach-form {
        max-width: 512px;
        margin: auto;
        width: 100%;

        background: white;
        box-shadow: 0 30px 60px 0 rgba(90, 116, 148, 0.4);
        border-radius: 10px;
        padding: 16px 0 16px 0;

        font-family: "SFProDisplay", sans-serif;
    }

    .ach-form__inner {
        padding: 16px;
    }

    .ach-form__row .ach-input {
        flex: 1 1 100px;
    }

    .ach-form__button {
        width: 100%;
        height: 55px;
        background: #009844;
        border: none;
        border-radius: 5px;
        font-size: 22px;
        font-weight: 500;

        box-shadow: 3px 10px 20px 0 rgba(35, 100, 210, 0.3);
        color: #fff;
        margin-top: 10px;
        cursor: pointer;
    }

    .ach-form__button:disabled {
        background: #A7A5A5;
        cursor: default;
    }

    .ach-input {
        margin-bottom: 16px;
    }

    .ach-input__label {
        font-size: 14px;
        margin-bottom: 5px;
        font-weight: 500;
        color: #1a3b5d;
        width: 100%;
        display: block;
    }

    .ach-input__input {
        width: 100%;
        min-width: 7.5rem;
        height: 50px;
        border-radius: 5px;
        box-shadow: none;
        border: 1px solid #ced6e0;
        transition: all 0.3s ease-in-out;
        font-size: 18px;
        padding: 5px 15px;
        background: none;
        color: #1a3b5d;
        font-family: "Source Sans Pro", sans-serif;
    }

    .ach-input__input:hover, .ach-input__input:focus {
        border-color: #3d9cff;
    }

    .ach-input__input:focus {
        box-shadow: 0 10px 20px -13px rgba(32, 56, 117, 0.35);
    }

    .ach-input__invalid {
        border-color: red;
    }

    .ach-input__error {
        color: red;
        font-style: italic;
    }

    .ach-input__success {
        color: #12B331;
    }

    .ach-input__result {
        margin-top: 16px;
        text-align: center;
        font-style: italic;
    }
</style>

<!-- Copyright (c) 2018, Livio, Inc. -->
<template>
    <div class="action-container">
        <h2 class="action-title">Delete Job</h2>
        <div v-if="errorMessage != null" class="error-container">
            <p class="action-text">Error: {{ errorMessage }}</p>
        </div>
        <div>
            <label class="action-label">ID: </label>
            <input class="action-text-input" type="text" v-model="idText">
        </div>
        <button v-on:click="deleteJob" class="action-button">Delete</button>
        <div v-if="manticoreResponse != null" class="response-container">
            <p class="action-text">Response [{{ responseTime }}] : {{ manticoreResponse }}</p>
        </div>
    </div>
</template>

<script>
import axios from 'axios';

export default {
    name: 'DeleteJob',
    data() {
        return {
            idText: '',
            errorMessage: null,
            manticoreResponse: null,
            responseTime: ''
        }
    },
    methods: {
        deleteJob() {
            var id = this.idText;
            axios.delete('/api/v2/job', {
                    data: {
                        id: id
                    }
                })
                .then((response) => {
                    this.manticoreResponse = response.data;
                    this.responseTime = new Date().toTimeString();
                    this.errorMessage = null;
                    this.$root.$data.deleteJob(id);
                })
                .catch((error) => {
                    this.errorMessage = error;
                    this.manticoreResponse = null;
                });
        }
    }
}
</script>

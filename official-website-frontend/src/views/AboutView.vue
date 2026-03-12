<script setup>
import { reactive } from 'vue'
import { submitContact } from '../services/api'

const form = reactive({
  name: '',
  contact: '',
  message: ''
})

const onSubmit = async () => {
  await submitContact(form)
  form.name = ''
  form.contact = ''
  form.message = ''
}
</script>

<template>
  <section class="section">
    <div class="container">
      <h2>关于我们</h2>
      <p>地址：杭州市 · 栩文科技有限公司</p>
      <div class="qr-grid">
        <div class="qr-box">企业二维码</div>
        <div class="qr-box">QQ二维码</div>
      </div>
      <form class="contact-form" @submit.prevent="onSubmit">
        <input v-model="form.name" placeholder="姓名" required />
        <input v-model="form.contact" placeholder="邮箱 / QQ" required />
        <textarea v-model="form.message" rows="4" placeholder="请输入需求描述" required />
        <button type="submit">提交需求</button>
      </form>
    </div>
  </section>
</template>

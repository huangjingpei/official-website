<template>
  <section class="section">
    <div class="container">
      <div style="text-align: center; margin-bottom: 2.5rem;">
        <h2>联系我们与商务合作</h2>
        <p style="color: var(--muted); margin: 0.4rem 0 0; font-size: 1.05rem;">
          无论您有技术咨询、产品体验需求，还是深度定制合作，我们随时在此倾听
        </p>
      </div>

      <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 2rem;">
        <!-- 左侧：需求留资表单 -->
        <div class="card" style="padding: 2rem;">
          <h3 style="margin-top: 0; color: var(--ink-0);">在线提交需求</h3>
          <p style="color: var(--muted); font-size: 0.95rem; margin-bottom: 1.5rem;">
            请留下您的联系方式与需求简述，我们的技术专家将在 2 个工作小时内与您联系。
          </p>

          <!-- 提交成功提示 -->
          <div
            v-if="submitSuccess"
            style="background: rgba(34, 197, 94, 0.12); border: 1px solid rgba(34, 197, 94, 0.35); color: #15803d; padding: 1rem; border-radius: 8px; margin-bottom: 1.2rem; font-weight: 500;"
          >
            ✅ 需求已成功提交！感谢您的关注，我们已收到您的信息并将尽快与您联系。
          </div>

          <form class="contact-form" @submit.prevent="onSubmit">
            <div>
              <label style="display: block; font-size: 0.9rem; font-weight: 600; margin-bottom: 0.4rem; color: var(--ink-0);">您的称呼 / 公司名称 *</label>
              <input v-model="form.name" placeholder="例如：张先生 / 某科技有限公司" required />
            </div>

            <div>
              <label style="display: block; font-size: 0.9rem; font-weight: 600; margin-bottom: 0.4rem; color: var(--ink-0);">联系方式 (手机 / 微信 / 邮箱) *</label>
              <input v-model="form.contact" placeholder="例如：13800000000 或 contact@example.com" required />
            </div>

            <div>
              <label style="display: block; font-size: 0.9rem; font-weight: 600; margin-bottom: 0.4rem; color: var(--ink-0);">业务需求或技术咨询 *</label>
              <textarea v-model="form.message" rows="4" placeholder="请简要描述您的业务场景、技术选型或希望了解的解决方案..." required />
            </div>

            <button type="submit" class="btn-primary" style="border: none; cursor: pointer; width: 100%; justify-content: center;" :disabled="submitting">
              {{ submitting ? '正在提交中...' : '立即提交需求' }}
            </button>
          </form>
        </div>

        <!-- 右侧：直接联系方式与扫码交流 -->
        <div style="display: flex; flex-direction: column; gap: 1.5rem;">
          <div class="card" style="padding: 2rem;">
            <h3 style="margin-top: 0; color: var(--ink-0);">直接联系</h3>
            <div style="display: grid; gap: 1rem; margin-top: 1.2rem; font-size: 0.95rem;">
              <div style="display: flex; align-items: center; gap: 0.8rem;">
                <span style="font-size: 1.3rem;">🏢</span>
                <div>
                  <strong style="color: var(--ink-0);">公司全称：</strong>
                  <span style="color: var(--muted);">杭州栩文科技有限公司</span>
                </div>
              </div>
              <div style="display: flex; align-items: center; gap: 0.8rem;">
                <span style="font-size: 1.3rem;">📍</span>
                <div>
                  <strong style="color: var(--ink-0);">办公地址：</strong>
                  <span style="color: var(--muted);">浙江省杭州市</span>
                </div>
              </div>
              <div style="display: flex; align-items: center; gap: 0.8rem;">
                <span style="font-size: 1.3rem;">📧</span>
                <div>
                  <strong style="color: var(--ink-0);">企业邮箱：</strong>
                  <a href="mailto:support@graddu.com" style="color: var(--accent);">support@graddu.com</a>
                </div>
              </div>
              <div style="display: flex; align-items: center; gap: 0.8rem;">
                <span style="font-size: 1.3rem;">📱</span>
                <div>
                  <strong style="color: var(--ink-0);">客服电话：</strong>
                  <a href="tel:13454118762" style="color: var(--accent);">13454118762</a>
                </div>
              </div>
              <div style="display: flex; align-items: center; gap: 0.8rem;">
                <span style="font-size: 1.3rem;">💬</span>
                <div>
                  <strong style="color: var(--ink-0);">客服QQ：</strong>
                  <span style="color: var(--muted);">278225113</span>
                </div>
              </div>
            </div>
          </div>

          <!-- 扫码即时沟通卡片 -->
          <div class="card" style="padding: 1.5rem; text-align: center;">
            <h4 style="margin: 0 0 1rem; color: var(--ink-0);">微信 / QQ 在线支持</h4>
            <div style="display: flex; justify-content: space-around; gap: 1rem; flex-wrap: wrap;">
              <div style="background: var(--bg-0); padding: 1rem; border-radius: 8px; border: 1px solid var(--stroke); width: 140px;">
                <div style="width: 100px; height: 100px; margin: 0 auto; background: #fff; border-radius: 6px; display: flex; align-items: center; justify-content: center; box-shadow: inset 0 0 4px rgba(0,0,0,0.1);">
                  <svg viewBox="0 0 24 24" style="width: 54px; height: 54px; fill: var(--accent);">
                    <path d="M4 4h7v7H4V4zm2 2v3h3V6H6zm7-2h7v7h-7V4zm2 2v3h3V6h-3zM4 13h7v7H4v-7zm2 2v3h3v-3H6zm10-1h-2v2h2v-2zm-3 2h2v2h-2v-2zm5 0h2v2h-2v-2zm-2 2h2v2h-2v-2zm2 2h2v2h-2v-2z" />
                  </svg>
                </div>
                <div style="font-size: 0.85rem; font-weight: 600; color: var(--ink-0); margin-top: 0.6rem;">微信专属客服</div>
              </div>

              <div style="background: var(--bg-0); padding: 1rem; border-radius: 8px; border: 1px solid var(--stroke); width: 140px;">
                <div style="width: 100px; height: 100px; margin: 0 auto; background: #fff; border-radius: 6px; display: flex; align-items: center; justify-content: center; box-shadow: inset 0 0 4px rgba(0,0,0,0.1);">
                  <svg viewBox="0 0 24 24" style="width: 54px; height: 54px; fill: #0284c7;">
                    <path d="M12 2C6.48 2 2 6.48 2 12c0 2.21.72 4.26 1.94 5.92L3 22l4.24-.91C8.83 21.64 10.37 22 12 22c5.52 0 10-4.48 10-10S17.52 2 12 2zm1 16h-2v-2h2v2zm0-4h-2V7h2v7z" />
                  </svg>
                </div>
                <div style="font-size: 0.85rem; font-weight: 600; color: var(--ink-0); margin-top: 0.6rem;">QQ 答疑支持</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { submitContact } from '../services/api'

const form = reactive({
  name: '',
  contact: '',
  message: ''
})

const submitting = ref(false)
const submitSuccess = ref(false)

const onSubmit = async () => {
  if (submitting.value) return
  submitting.value = true
  submitSuccess.value = false

  try {
    await submitContact(form)
    submitSuccess.value = true
    form.name = ''
    form.contact = ''
    form.message = ''
  } catch (error) {
    alert('提交失败，请检查网络或稍后重试，或通过电话/邮箱直接联系我们。')
  } finally {
    submitting.value = false
  }
}
</script>

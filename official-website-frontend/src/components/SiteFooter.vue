<template>
  <footer class="site-footer">
    <div class="container footer-grid-4">
      <!-- 品牌愿景 -->
      <div>
        <h4>杭州栩文科技</h4>
        <p style="color: #cbd5e1; font-size: 0.95rem; line-height: 1.6; margin-top: 0.5rem;">
          专注于 AI 与音视频融合技术，为行业提供低延迟、高可靠、可快速落地的智能互动解决方案。
        </p>
      </div>

      <!-- 核心方案 -->
      <div>
        <h4>技术方案</h4>
        <ul class="core-list">
          <li><RouterLink to="/solutions?focus=webrtc" style="color: inherit;">WebRTC 实时互动</RouterLink></li>
          <li><RouterLink to="/solutions?focus=remote" style="color: inherit;">远程桌面协同</RouterLink></li>
          <li><RouterLink to="/solutions?focus=danmaku" style="color: inherit;">高并发实时弹幕</RouterLink></li>
          <li><RouterLink to="/solutions?focus=ai" style="color: inherit;">AI 实时语音交互</RouterLink></li>
        </ul>
      </div>

      <!-- 软件与资源 -->
      <div>
        <h4>资源支持</h4>
        <ul class="core-list">
          <li><RouterLink to="/downloads" style="color: inherit;">Penclaw 客户端</RouterLink></li>
          <li><RouterLink to="/downloads" style="color: inherit;">软件下载中心</RouterLink></li>
          <li><RouterLink to="/news" style="color: inherit;">技术发版动态</RouterLink></li>
          <li><RouterLink to="/about" style="color: inherit;">需求与技术支持</RouterLink></li>
        </ul>
      </div>

      <!-- 联系方式 -->
      <div>
        <h4>商务合作</h4>
        <p style="color: #e2e8f0; margin: 0.4rem 0;">邮箱：support@graddu.com</p>
        <p style="color: #e2e8f0; margin: 0.4rem 0;">电话：13454118762</p>
        <p style="color: #e2e8f0; margin: 0.4rem 0;">客服QQ：278225113</p>
        <p style="color: #cbd5e1; font-size: 0.85rem; margin-top: 0.4rem;">地址：浙江省 · 杭州市</p>
      </div>
    </div>

    <!-- 资质与版权合规条 -->
    <div class="container icp-footer">
      <div class="company-name">杭州栩文科技有限公司</div>
      <div class="icp-number">
        <a href="https://beian.miit.gov.cn/" target="_blank" rel="noopener noreferrer">
          浙ICP备2021037087号-1
        </a>
      </div>
      <div class="copyright">
        © 2024 graddu.com 版权所有 | 本网站为杭州栩文科技有限公司所有
      </div>
      <div class="legal-links">
        <RouterLink to="/privacy" style="color: #94a3b8; text-decoration: none; margin: 0 .4rem;">隐私保护指引</RouterLink>
        <span style="color: #475569;">|</span>
        <RouterLink to="/terms" style="color: #94a3b8; text-decoration: none; margin: 0 .4rem;">用户服务协议</RouterLink>
      </div>
    </div>
  </footer>
</template>

<script setup>
import { RouterLink } from 'vue-router'
</script>

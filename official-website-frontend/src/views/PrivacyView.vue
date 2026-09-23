<template>
  <div class="legal-page">
    <div class="legal-container">
      <h1>隐私保护指引</h1>
      <p class="legal-updated">最后更新：2026年9月23日 &nbsp;|&nbsp; 杭州栩文科技有限公司</p>

      <section>
        <h2>一、总则</h2>
        <p>杭州栩文科技有限公司（以下简称"栩文科技"或"我们"）深知个人信息对您的重要性，并会尽全力保护您的个人信息安全可靠。本隐私保护指引适用于 <strong>graddu.com</strong> 及其子域名下的所有服务。</p>
      </section>

      <section>
        <h2>二、我们收集的信息</h2>
        <p>我们可能收集以下类型的信息：</p>
        <ul>
          <li><strong>主动提供的信息：</strong>当您通过"关于我们"页面的联系表单向我们提交需求时，我们会收集您的姓名/公司名称、联系方式（手机号/邮箱）及您的需求描述。</li>
          <li><strong>自动采集的日志信息：</strong>在您使用本网站时，服务器可能自动记录您的访问时间、浏览器类型、操作系统、来源页面及 IP 地址，用于网站安全监控和访问统计。</li>
          <li><strong>软件下载信息：</strong>当您下载 Penclaw 等软件时，我们会记录下载请求的基本信息，不会关联您的个人身份。</li>
        </ul>
      </section>

      <section>
        <h2>三、信息的使用目的</h2>
        <p>我们收集的信息仅用于以下目的：</p>
        <ul>
          <li>回复您的商务咨询、技术支持需求；</li>
          <li>提升网站服务质量和安全性；</li>
          <li>统计分析访问数据（不涉及个人身份识别）；</li>
          <li>依法履行法律义务。</li>
        </ul>
        <p>我们不会将您的个人信息用于与上述目的无关的任何场景，也不会在未经您同意的情况下将其出售、出租或共享给任何第三方。</p>
      </section>

      <section>
        <h2>四、信息的存储与保护</h2>
        <p>您的个人信息存储于中国大陆地区的服务器（阿里云），并采取如下措施进行保护：</p>
        <ul>
          <li>网站全站启用 HTTPS（TLS 1.2+）加密传输；</li>
          <li>敏感数据访问受权限管控，仅授权人员可查看；</li>
          <li>联系表单提交记录定期清理，保留不超过 180 天。</li>
        </ul>
      </section>

      <section>
        <h2>五、Cookie 与本地存储</h2>
        <p>本网站仅使用浏览器本地存储（localStorage）保存以下数据，无 Cookie 跟踪行为：</p>
        <ul>
          <li>您选择的界面主题偏好（ui-theme）；</li>
          <li>管理员登录凭据（仅限管理员会话，明文存储 Base64，请在公共计算机上使用后手动退出登录）。</li>
        </ul>
        <p>我们不使用任何第三方广告追踪 Cookie。</p>
      </section>

      <section>
        <h2>六、您的权利</h2>
        <p>您有权请求我们：</p>
        <ul>
          <li>查阅我们持有的您的个人信息；</li>
          <li>更正不准确的个人信息；</li>
          <li>删除您提交的联系表单信息。</li>
        </ul>
        <p>如需行使上述权利，请通过以下联系方式与我们联系，我们将在 15 个工作日内回复。</p>
      </section>

      <section>
        <h2>七、联系我们</h2>
        <p>若您对本隐私保护指引有任何疑问，请通过以下方式联系：</p>
        <ul>
          <li>邮箱：<a href="mailto:support@graddu.com">support@graddu.com</a></li>
          <li>电话：13454118762</li>
          <li>地址：浙江省杭州市</li>
        </ul>
      </section>

      <section>
        <h2>八、本指引的变更</h2>
        <p>我们可能会不定期更新本隐私保护指引。重大变更时，我们将在网站首页发布通知。更新后继续使用本网站，视为您接受新版本的隐私保护指引。</p>
      </section>
    </div>
  </div>
</template>

<style scoped>
.legal-page {
  min-height: 80vh;
  background: var(--surface);
  padding: 3rem 1rem 4rem;
}
.legal-container {
  max-width: 800px;
  margin: 0 auto;
  background: var(--card-bg, #fff);
  border-radius: 16px;
  padding: 2.5rem 3rem;
  box-shadow: 0 2px 16px rgba(0,0,0,.07);
}
h1 {
  font-size: 1.8rem;
  font-weight: 800;
  color: var(--text-primary);
  margin: 0 0 .5rem;
}
.legal-updated {
  color: var(--muted);
  font-size: .875rem;
  margin-bottom: 2rem;
  padding-bottom: 1.2rem;
  border-bottom: 1px solid var(--border, #e2e8f0);
}
section { margin-bottom: 1.8rem; }
h2 {
  font-size: 1.1rem;
  font-weight: 700;
  color: var(--text-primary);
  margin: 0 0 .6rem;
}
p, li {
  font-size: .95rem;
  color: var(--text-secondary, #475569);
  line-height: 1.8;
}
ul { padding-left: 1.4rem; }
li { margin-bottom: .3rem; }
a { color: var(--accent, #2563eb); text-decoration: none; }
a:hover { text-decoration: underline; }

@media (max-width: 600px) {
  .legal-container { padding: 1.5rem 1.2rem; }
  h1 { font-size: 1.4rem; }
}
</style>

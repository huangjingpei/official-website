<template>
  <div class="legal-page">
    <div class="legal-container">
      <h1>用户服务协议</h1>
      <p class="legal-updated">最后更新：2026年9月23日 &nbsp;|&nbsp; 杭州栩文科技有限公司</p>

      <section>
        <h2>一、协议说明</h2>
        <p>本用户服务协议（以下简称"协议"）由您与杭州栩文科技有限公司（以下简称"栩文科技"）签订，规定您访问和使用 <strong>graddu.com</strong> 网站及其提供的技术服务的权利与义务。访问或使用本网站，即视为您已阅读、理解并同意本协议全部条款。</p>
      </section>

      <section>
        <h2>二、服务内容</h2>
        <p>栩文科技通过本网站提供以下服务：</p>
        <ul>
          <li>企业技术方案展示（WebRTC 实时音视频、远程桌面、实时弹幕、AI 交互）；</li>
          <li>Penclaw 等软件产品的版本发布与下载；</li>
          <li>实时要闻与技术动态资讯；</li>
          <li>商务需求在线留资与咨询通道。</li>
        </ul>
      </section>

      <section>
        <h2>三、用户行为规范</h2>
        <p>您在使用本网站时，不得：</p>
        <ul>
          <li>通过自动化工具或脚本对本网站发起频繁请求（爬虫、DDoS 等）；</li>
          <li>上传、发布任何违法、有害、侮辱性或侵权内容；</li>
          <li>尝试未经授权访问后台管理系统或破解安全措施；</li>
          <li>利用本网站从事任何商业欺诈或违法活动。</li>
        </ul>
      </section>

      <section>
        <h2>四、软件下载条款</h2>
        <p>通过本网站下载的软件（如 Penclaw）均受著作权保护，用户仅获得个人使用授权，不得：</p>
        <ul>
          <li>对软件进行反编译、逆向工程或破解；</li>
          <li>将软件用于商业转售或分发；</li>
          <li>删除软件中的版权声明或品牌标识。</li>
        </ul>
        <p>软件以"现状"提供，栩文科技不对因软件缺陷导致的直接或间接损失承担责任。</p>
      </section>

      <section>
        <h2>五、知识产权声明</h2>
        <p>本网站的所有内容，包括但不限于文字、图片、视频、代码、设计方案及技术架构图，均属于栩文科技的知识产权或已获合法授权使用。未经书面授权，不得以任何形式复制、转载、修改或传播。</p>
      </section>

      <section>
        <h2>六、免责声明</h2>
        <p>在法律允许的最大范围内，栩文科技对以下情形不承担责任：</p>
        <ul>
          <li>因不可抗力（地震、洪水、战争、政府行为、网络攻击等）导致的服务中断；</li>
          <li>因您违反本协议或法律法规造成的损失；</li>
          <li>因第三方服务故障（CDN、云服务商等）导致的访问异常。</li>
        </ul>
      </section>

      <section>
        <h2>七、争议解决</h2>
        <p>本协议的签订、生效、解释及争议解决均适用中华人民共和国法律。因本协议引起的争议，双方应首先协商解决；协商不成时，提交杭州市有管辖权的人民法院诉讼解决。</p>
      </section>

      <section>
        <h2>八、联系方式</h2>
        <p>如您对本协议有任何疑问，请联系：</p>
        <ul>
          <li>邮箱：<a href="mailto:support@graddu.com">support@graddu.com</a></li>
          <li>电话：13454118762</li>
          <li>公司：杭州栩文科技有限公司，浙江省杭州市</li>
        </ul>
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

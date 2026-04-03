export interface BioRequest {
  name: string;
  degree?: string;
  specialization?: string;
  experience_years?: number;
  success_rate?: string;
  hospital?: string;
  role?: string;
  skills?: string[];
  tone?: 'professional' | 'friendly' | 'short' | 'detailed';
  language?: 'english' | 'hindi';
}

const BACKEND_URL = (import.meta as any).env?.VITE_API_URL || 'http://localhost:8000';

// ── Mock fallback (runs when backend is unavailable) ─────────────────────────

function mockGenerateBio(req: BioRequest): string {
  const name = req.name || 'The Doctor';
  const last = name.split(' ').slice(-1)[0];
  const spec = req.specialization || 'medicine';
  const exp = req.experience_years ?? 0;
  const hospital = req.hospital || 'a leading medical institution';
  const role = req.role || 'Consultant';
  const degree = req.degree || '';
  const success = req.success_rate || '';
  const skills = req.skills || [];
  const tone = req.tone || 'professional';
  const lang = req.language || 'english';

  if (lang === 'hindi') {
    const successPart = success ? ` उनकी सफलता दर ${success} है।` : '';
    const skillsPart = skills.length > 0
      ? ` वे ${skills.join(', ')} में विशेषज्ञता रखते हैं।`
      : ` वे उन्नत ${spec} उपचार और निवारक देखभाल में विशेषज्ञ हैं।`;
    return (
      `${name} एक अनुभवी ${spec} विशेषज्ञ हैं जिनके पास ${exp} से अधिक वर्षों का नैदानिक अनुभव है।` +
      (degree ? ` वे ${degree} की उपाधि धारण करते हैं।` : '') +
      ` वे वर्तमान में ${hospital} में ${role} के रूप में कार्यरत हैं।` +
      successPart +
      ' वे रोगी-केंद्रित दृष्टिकोण के लिए जाने जाते हैं।' +
      skillsPart
    ).trim();
  }

  const degreeText = degree ? `They hold ${degree} and are ` : 'They are ';
  const hospitalPart = `currently serving as ${role} at ${hospital}`;
  const successPart = success ? ` with a ${success} success rate` : '';
  const skillsPart = skills.length > 0
    ? `Areas of expertise include: ${skills.join(', ')}.`
    : `Specializing in advanced ${spec} treatments and preventive care.`;

  if (tone === 'friendly') {
    return (
      `Hi! I'm ${name}, a passionate ${spec} with over ${exp} years of experience helping patients live healthier lives.` +
      (degree ? ` I hold ${degree}.` : '') +
      ` I'm ${hospitalPart}${successPart}. I believe in making healthcare accessible, comfortable, and personalized for every patient. ` +
      skillsPart
    ).trim();
  }

  if (tone === 'short') {
    return (
      `${name} — ${spec} specialist with ${exp}+ years of experience.` +
      (degree ? ` ${degree}.` : '') +
      ` ${hospitalPart.charAt(0).toUpperCase() + hospitalPart.slice(1)}${successPart}. ` +
      skillsPart
    ).trim();
  }

  if (tone === 'detailed') {
    return (
      `${name} is a distinguished ${spec} with an extensive clinical career spanning over ${exp} years.` +
      (degree
        ? ` Holding ${degree}, they bring exceptional academic and clinical expertise to every patient interaction.`
        : '') +
      ` Dr. ${last} is ${hospitalPart}${successPart}. ` +
      `Throughout their career, they have demonstrated outstanding proficiency in diagnosing and managing complex conditions. ` +
      `Their commitment to evidence-based medicine and continuous medical education ensures the highest standard of care. ` +
      skillsPart +
      ` Their dedication to research and innovation reinforces their standing as a leader in the field.`
    ).trim();
  }

  // Professional (default)
  return (
    `${name} is a highly experienced ${spec} with over ${exp} years of clinical expertise. ` +
    degreeText +
    `${hospitalPart}${successPart}. ` +
    `Known for a patient-centered approach and unwavering commitment to excellence, Dr. ${last} delivers accurate diagnosis and effective treatment. ` +
    skillsPart
  ).trim();
}

// ── Service ──────────────────────────────────────────────────────────────────

export const aiProfileService = {
  async generateBio(req: BioRequest): Promise<string> {
    try {
      const res = await fetch(`${BACKEND_URL}/api/v1/profile-ai/generate-bio`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(req),
        signal: AbortSignal.timeout(5000),
      });
      if (!res.ok) throw new Error('Backend error');
      const data = await res.json();
      return data.bio as string;
    } catch {
      // Simulate network delay, then fall back to mock
      await new Promise(r => setTimeout(r, 900 + Math.random() * 400));
      return mockGenerateBio(req);
    }
  },
};

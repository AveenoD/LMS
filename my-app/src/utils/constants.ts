import {
  LayoutDashboard,
  Users,
  ClipboardCheck,
  IndianRupee,
  Video,
  FileText,
  BookOpen,
  BarChart3,
  Shield,
  MessageCircle,
  Clock,
  TrendingUp,
  type LucideIcon,
} from "lucide-react";

/* ───────── Navigation ───────── */
export interface NavLink {
  label: string;
  href: string;
  children?: NavLink[];
}

export const NAV_LINKS: NavLink[] = [
  { label: "Home", href: "/" },
  {
    label: "Features",
    href: "/features",
  },
  { label: "How It Works", href: "/how-it-works" },
  { label: "Pricing", href: "/pricing" },
  { label: "Demo", href: "/demo" },
  { label: "About Us", href: "/about" },
  { label: "Contact", href: "/contact" },
];

/* ───────── Trust Badges ───────── */
export interface TrustItem {
  icon: LucideIcon;
  title: string;
  subtitle: string;
}

export const TRUST_BADGES: TrustItem[] = [
  { icon: Users, title: "1000+ Institutes", subtitle: "Trust Campus" },
  { icon: Clock, title: "24/7 Support", subtitle: "We're here to help" },
  { icon: Shield, title: "Secure & Reliable", subtitle: "Your data is safe" },
  {
    icon: TrendingUp,
    title: "99.9% Uptime",
    subtitle: "Always available",
  },
];

/* ───────── Key Features (Home) ───────── */
export interface Feature {
  icon: LucideIcon;
  title: string;
  description: string;
  highlights?: string[];
  href?: string;
}

export const KEY_FEATURES: Feature[] = [
  {
    icon: LayoutDashboard,
    title: "Dashboard",
    description:
      "Get a complete overview of your institute in one place.",
  },
  {
    icon: Users,
    title: "Students",
    description:
      "Manage student details, batches and all academic information.",
  },
  {
    icon: ClipboardCheck,
    title: "Attendance",
    description: "Mark attendance easily by batch, date or custom range.",
  },
  {
    icon: IndianRupee,
    title: "Fees",
    description: "Track fees, collect online payments and send reminders.",
  },
  {
    icon: Video,
    title: "Live Classes",
    description: "Conduct live classes via Google Meet seamlessly.",
  },
  {
    icon: FileText,
    title: "Tests & Exams",
    description:
      "Create tests, evaluate automatically and analyze performance.",
  },
  {
    icon: BookOpen,
    title: "Assignments",
    description:
      "Share assignments, collect submissions and provide feedback.",
  },
  {
    icon: BarChart3,
    title: "Reports & Analytics",
    description: "Powerful reports and analytics to make smart decisions.",
  },
];

/* ───────── Detailed Features (/features) ───────── */
export interface DetailedFeature {
  icon: LucideIcon;
  title: string;
  description: string;
  highlights: string[];
}

export const DETAILED_FEATURES: DetailedFeature[] = [
  {
    icon: LayoutDashboard,
    title: "Dashboard",
    description: "Get real-time overview of your institute's performance.",
    highlights: ["Students count", "Attendance %", "Fee collection stats"],
  },
  {
    icon: Users,
    title: "Students Management",
    description:
      "Manage student profiles, batches, courses and academic progress.",
    highlights: ["Student profiles", "Batch management", "Course tracking"],
  },
  {
    icon: ClipboardCheck,
    title: "Attendance Tracking",
    description:
      "Mark attendance easily by batch, date or individual student.",
    highlights: ["Batch-wise attendance", "Date filter", "Student records"],
  },
  {
    icon: IndianRupee,
    title: "Fees Management",
    description:
      "Track fees, manage dues and send reminders straight to WhatsApp.",
    highlights: ["Online payments", "Due reminders", "Payment history"],
  },
  {
    icon: Video,
    title: "Live Classes",
    description:
      "Take live classes with Google Meet integration in one click.",
    highlights: ["Google Meet", "Scheduled classes", "Upcoming classes view"],
  },
  {
    icon: BookOpen,
    title: "Video Library",
    description:
      "Upload, organize and share recorded lectures with students anytime.",
    highlights: ["Subject-wise library", "Upload lectures", "Student access"],
  },
  {
    icon: FileText,
    title: "Tests & Exams",
    description:
      "Create tests, auto evaluate and analyze performance instantly.",
    highlights: ["Auto evaluation", "Performance analytics", "Score tracking"],
  },
  {
    icon: BarChart3,
    title: "Reports & Analytics",
    description:
      "Powerful reports and analytics to make smart decisions.",
    highlights: ["Performance charts", "Trend analysis", "Export data"],
  },
];

/* ───────── How It Works ───────── */
export interface Step {
  step: number;
  title: string;
  description: string;
  subtext: string;
}

export const HOW_IT_WORKS_STEPS: Step[] = [
  {
    step: 1,
    title: "Book a Free Demo",
    description:
      "Schedule a demo with our expert and see how Campus can transform your institute.",
    subtext: "Takes less than 30 seconds",
  },
  {
    step: 2,
    title: "Quick Setup in 24 Hours",
    description:
      "We set up your institute, customize your brand and import your data.",
    subtext: "Go live within 24 hours",
  },
  {
    step: 3,
    title: "Add Students & Teachers",
    description:
      "Invite students and teachers, create batches and start your academic journey.",
    subtext: "Unlimited users",
  },
  {
    step: 4,
    title: "Start Managing & Growing",
    description:
      "Manage attendance, fees, live classes and more from one powerful dashboard.",
    subtext: "All-in-one management",
  },
];

/* ───────── USP Bar (How It Works page) ───────── */
export interface USPItem {
  icon: LucideIcon;
  title: string;
  description: string;
}

export const USP_ITEMS: USPItem[] = [
  {
    icon: Shield,
    title: "100% Secure",
    description: "Your data is encrypted and always protected.",
  },
  {
    icon: MessageCircle,
    title: "Free WhatsApp Reminders",
    description: "One-tap WhatsApp messages for fees, attendance and more.",
  },
  {
    icon: Users,
    title: "Made for Coaching Institutes",
    description: "Every feature is designed keeping your daily needs in mind.",
  },
  {
    icon: TrendingUp,
    title: "Always Improving",
    description:
      "We keep adding new features to help your institute grow faster.",
  },
];

/* ───────── Pricing Guarantee Badges ───────── */
export const PRICING_BADGES = [
  "7 Days Free Trial",
  "No Credit Card Required",
  "Cancel Anytime",
  "Trusted by 1000+ Institutes",
];

/* ───────── FAQs ───────── */
export interface FAQ {
  question: string;
  answer: string;
}

export const FAQS: FAQ[] = [
  {
    question: "Is there a free trial available?",
    answer:
      "Yes! We offer a 7-day free trial on all plans. No credit card required to get started.",
  },
  {
    question: "Can I upgrade or downgrade my plan later?",
    answer:
      "Absolutely. You can switch plans anytime from your account settings. Changes will be reflected in the next billing cycle.",
  },
  {
    question: "Do you offer annual billing?",
    answer:
      "Yes, we offer annual billing with up to 20% discount on all plans. Contact our sales team for details.",
  },
  {
    question: "What payment methods do you accept?",
    answer:
      "We accept UPI, credit/debit cards, net banking and wallet payments through Razorpay.",
  },
  {
    question: "Is my data secure with Campus?",
    answer:
      "Your data is encrypted with industry-standard SSL encryption and stored securely on AWS servers in India.",
  },
  {
    question: "Can I get a custom plan for my institute?",
    answer:
      "Yes, for institutes with specific needs, we offer custom plans. Contact our sales team to discuss your requirements.",
  },
];

/* ───────── Footer Links ───────── */
export const FOOTER_LINKS = {
  product: [
    { label: "Features", href: "/features" },
    { label: "How It Works", href: "/how-it-works" },
    { label: "Pricing", href: "/pricing" },
    { label: "Demo", href: "/demo" },
  ],
  solutions: [
    { label: "For Coaching Institutes", href: "#" },
    { label: "For Teachers", href: "#" },
    { label: "For Students & Parents", href: "#" },
  ],
  resources: [
    { label: "Blog", href: "#" },
    { label: "Help Center", href: "#" },
    { label: "Privacy Policy", href: "#" },
    { label: "Terms & Conditions", href: "#" },
  ],
  company: [
    { label: "About Us", href: "/about" },
    { label: "Contact Us", href: "/contact" },
  ],
};

/* ───────── Resources Page ───────── */
export const RESOURCE_CATEGORIES = [
  {
    icon: BookOpen,
    title: "Guides & Ebooks",
    description: "Step-by-step guides for your institute",
  },
  {
    icon: FileText,
    title: "Blog Articles",
    description: "Tips, trends and best practices",
  },
  {
    icon: ClipboardCheck,
    title: "Templates",
    description: "Ready-to-use templates & checklists",
  },
  {
    icon: Video,
    title: "Webinars",
    description: "Watch expert sessions on-demand",
  },
  {
    icon: BarChart3,
    title: "Case Studies",
    description: "Real stories from real institutes",
  },
  {
    icon: MessageCircle,
    title: "Help Center",
    description: "Get answers to your questions",
  },
];

export const LATEST_RESOURCES = [
  {
    id: 1,
    badge: "GUIDE",
    title: "Complete Institute Setup Checklist",
    description: "A step-by-step checklist to set up your coaching institute for success.",
    image: "/placeholder-guide.jpg",
    readTime: "6 min read",
    type: "PDF",
  },
  {
    id: 2,
    badge: "BLOG",
    title: "10 Ways to Improve Student Retention",
    description: "Proven strategies to keep students engaged and coming back.",
    image: "/placeholder-blog.jpg",
    readTime: "8 min read",
    type: "Read More",
  },
  {
    id: 3,
    badge: "TEMPLATE",
    title: "Daily Class Report Template",
    description: "Track class performance, attendance and topics with this free template.",
    image: "/placeholder-template.jpg",
    readTime: "Download",
    type: "Excel",
  },
  {
    id: 4,
    badge: "WEBINAR",
    title: "Digital Transformation for Coaching Institutes",
    description: "Learn how technology can help you scale your institute effectively.",
    image: "/placeholder-webinar.jpg",
    readTime: "45 min",
    type: "Watch Now",
  }
];

export const POPULAR_TOPICS = [
  "Institute Management",
  "Student Engagement",
  "Online Classes",
  "Fees & Payments",
  "Marketing",
  "Growth Strategies"
];


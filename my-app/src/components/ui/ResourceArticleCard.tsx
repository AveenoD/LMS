import React from "react";
import Image from "next/image";
import { Clock, FileText, ArrowRight, Play, Download } from "lucide-react";

interface ResourceArticleCardProps {
  badge: string;
  title: string;
  description: string;
  image: string;
  readTime: string;
  type: string;
}

export default function ResourceArticleCard({
  badge,
  title,
  description,
  image,
  readTime,
  type,
}: ResourceArticleCardProps) {
  // Determine icon based on type
  const getTypeIcon = () => {
    switch (type.toLowerCase()) {
      case "pdf":
        return <FileText className="w-4 h-4" />;
      case "excel":
        return <Download className="w-4 h-4" />;
      case "watch now":
        return <ArrowRight className="w-4 h-4" />; 
      case "read more":
      default:
        return <ArrowRight className="w-4 h-4" />;
    }
  };

  return (
    <div className="group flex flex-col bg-white rounded-2xl overflow-hidden border border-paper shadow-sm hover:shadow-card-hover transition-all duration-300 h-full cursor-pointer">
      {/* Image Container */}
      <div className="relative aspect-[4/3] overflow-hidden bg-paper flex items-center justify-center">
        {/* Placeholder div before actual images arrive. */}
        <span className="text-ink-green/20 font-display font-bold text-xl">{badge}</span>
        
        {/* Badge Overlay */}
        <div className="absolute top-4 left-4 z-10">
          <span className="bg-ink-green text-white text-[10px] font-bold tracking-wider uppercase px-2.5 py-1 rounded-md">
            {badge}
          </span>
        </div>
      </div>

      {/* Content */}
      <div className="flex flex-col flex-1 p-6">
        <h3 className="text-xl font-display font-bold text-ink-green mb-3 group-hover:text-chalk-teal transition-colors">
          {title}
        </h3>
        <p className="text-ink-green/70 text-sm font-body leading-relaxed mb-6 flex-1">
          {description}
        </p>

        {/* Footer */}
        <div className="flex items-center justify-between pt-4 border-t border-paper/60 mt-auto">
          <div className="flex items-center gap-1.5 text-ink-green/60 text-xs font-body">
            <Clock className="w-4 h-4" />
            <span>{readTime}</span>
          </div>
          <button className="flex items-center gap-1.5 text-ink-green font-bold text-sm hover:text-chalk-teal transition-colors">
            {type}
            {getTypeIcon()}
          </button>
        </div>
      </div>
    </div>
  );
}

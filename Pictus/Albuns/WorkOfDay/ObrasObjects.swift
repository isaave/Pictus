//
//  ObrasObjects.swift
//  Pictus
//
//  Created by Andre on 18/08/26.
//

import UIKit

struct ObrasObjects{
    var alreadyRoller = false
    
    var obrasDesconhecidas: [ArtEntity] = [
        ArtEntity(
            name: "Stánczyk",
            authorName: "Jan Matejko",
            date: Calendar.current.date(from: DateComponents(year: 1862, month: 10, day: 10)),
            local: "Polônia",
            img: UIImage(named: "Image 1")?.jpegData(compressionQuality: 0.1),
            ctxArt: "Ambientada na Polônia do século XVI, a pintura retrata Stańczyk, o lendário bobo da corte conhecido por sua inteligência e franqueza. Enquanto um baile acontece ao fundo, ele permanece sozinho, mergulhado em seus próprios pensamentos, criando um contraste marcante entre a celebração e o silêncio.",
            ctxReleased: false,
            origin: "Descobertas"
        ),
        
        ArtEntity(
            name: "Céu de Ataíde",
            authorName: "Mestre Ataíde",
            date: Calendar.current.date(from: DateComponents(year: 1812, month: 10, day: 10)),
            local: "",
            img: UIImage(named: "Image 3")?.jpegData(compressionQuality: 0.1),
            ctxArt: "O Céu de Ataíde é a famosa pintura em perspectiva do teto da nave da Igreja de São Francisco de Assis de Ouro Preto, criada por Manuel da Costa Ataíde, o Mestre Ataíde, entre 1801 e 1812. A obra-prima do barroco mineiro retrata a Assunção da Virgem Maria cercada por anjos com traços mestiços e tons de pele morena, sob um célebre fundo azul que dá a ilusão de que o teto da igreja se abre para o paraíso.",
            ctxReleased: false,
            origin: "Descobertas"
        ),
        
        ArtEntity(
            name: "Fiel até a morte",
            authorName: "Edward Poynter",
            date: Calendar.current.date(from: DateComponents(year: 1865, month: 10, day: 10)),
            local: "",
            img: UIImage(named: "ArtCover")?.jpegData(compressionQuality: 0.1),
            ctxArt: "Tema Histórico: A obra retrata a erupção do Monte Vesúvio em 79 d.C. e a destruição de Pompeia. Ela se baseia na lenda popular de um soldado romano que permaneceu em seu posto de guarda até o fim, recusando-se a fugir.O Soldado: Em vez de focar em um grande general, Poynter retrata um soldado comum ereto e imóvel. Seus pés firmes no chão e sua mão segurando a lança demonstram obediência militar e sacrifício diante do perigo.O Cenário de Fogo: Ao fundo, o cenário exibe caos, bolas de fogo, pessoas fugindo e mortas no chão, além de riquezas abandonadas que não puderam evitar a morte.Uso de Cores e Linhas: Tons quentes como laranja, vermelho e amarelo predominam para mostrar a destruição. A linha central da tela divide a imobilidade heroica do soldado e o frenesi do fundo",
            ctxReleased: false,
            origin: "Descobertas"
        ),
        
        ArtEntity(
            name: "A criação de adão",
            authorName: "Michelangelo",
            date: Calendar.current.date(from: DateComponents(year: 1511, month: 10, day: 10)),
            local: "",
            img: UIImage(named: "Image 2")?.jpegData(compressionQuality: 0.1),
            ctxArt: "O Quase Toque: O espaço pequeno entre o dedo de Deus e o dedo de Adão mostra o momento antes da centelha da vida passar para o homem.Posturas: Deus surge em movimento, cercado por anjos. Adão fica deitado de forma relaxada, esperando a energia vital.Forma do Manto: O tecido vermelho ao redor de Deus tem o formato parecido com um cérebro humano, o que simboliza a mente e a razão divina",
            ctxReleased: false,
            origin: "Descobertas"
        ),
        
        ArtEntity(
                    name: "A Noite Estrelada",
                    authorName: "Vincent van Gogh",
                    date: Calendar.current.date(from: DateComponents(year: 1889, month: 6, day: 18)),
                    local: "França",
                    img: UIImage(named: "Image 4")?.jpegData(compressionQuality: 0.1),
                    ctxArt: "Movimento e Emoção: As pinceladas espessas e circulares no céu expressam a turbulência emocional do artista, que pintou a obra enquanto estava no asilo de Saint-Paul-de-Mausole. O Cipreste: A árvore escura no primeiro plano simboliza a morte e a eternidade, agindo como uma ponte entre a terra e o céu. Contraste de Cores: O amarelo vibrante das estrelas e da lua contrasta fortemente com os tons profundos de azul do céu noturno e da vila adormecida abaixo.",
                    ctxReleased: false,
                    origin: "Descobertas"
                ),
                
                ArtEntity(
                    name: "Abaporu",
                    authorName: "Tarsila do Amaral",
                    date: Calendar.current.date(from: DateComponents(year: 1928, month: 1, day: 11)),
                    local: "Brasil",
                    img: UIImage(named: "Image 5")?.jpegData(compressionQuality: 0.1),
                    ctxArt: "Símbolo Antropofágico: O nome vem do tupi e significa 'homem que come gente'. A pintura inspirou o Movimento Antropofágico, que propunha absorver a cultura europeia e transformá-la em algo puramente brasileiro. Proporções Exageradas: A figura solitária possui pés e mãos enormes, simbolizando a ligação com a terra, enquanto a cabeça pequena representa a desvalorização do trabalho intelectual na época. Elementos Nacionais: O cacto e o sol compõem uma paisagem usando as cores da bandeira nacional.",
                    ctxReleased: false,
                    origin: "Descobertas"
                ),
                
                ArtEntity(
                    name: "O Beijo",
                    authorName: "Gustav Klimt",
                    date: Calendar.current.date(from: DateComponents(year: 1908, month: 10, day: 10)),
                    local: "Áustria",
                    img: UIImage(named: "Image 6")?.jpegData(compressionQuality: 0.1),
                    ctxArt: "Fase Dourada: A obra é o ponto alto da Fase Dourada de Klimt, onde ele utilizou folhas de ouro misturadas à tinta a óleo para criar um efeito radiante e sagrado em torno dos amantes. Fusão dos Corpos: O casal parece se fundir em uma única forma, envolto por mantos com padrões geométricos que diferenciam os sexos (retângulos para ele, círculos e flores para ela). Abstração e Realismo: Enquanto os rostos são pintados de forma realista, o restante da composição dissolve-se em abstração.",
                    ctxReleased: false,
                    origin: "Descobertas"
                ),
                
                
                ArtEntity(
                    name: "A Moça com o Brinco de Pérola",
                    authorName: "Johannes Vermeer",
                    date: Calendar.current.date(from: DateComponents(year: 1665, month: 10, day: 10)),
                    local: "Holanda",
                    img: UIImage(named: "Image 7")?.jpegData(compressionQuality: 0.1),
                    ctxArt: "O Foco na Luz: Vermeer era um mestre da iluminação. A luz incide suavemente no rosto da jovem e destaca brilhantemente o brinco de pérola, que é o ponto focal da tela. O Olhar Enigmático: A garota é capturada em um momento fugaz, olhando por cima do ombro com os lábios levemente entreabertos, o que confere uma intimidade imediata à obra. Fundo Escuro: Diferente de muitos retratos da época, o fundo é totalmente escuro e vazio, o que aumenta o contraste e dá uma sensação de tridimensionalidade à figura.",
                    ctxReleased: false,
                    origin: "Descobertas"
                )
    ]
    
    var obrasConhecidas: [ArtEntity] = [
        
    ]
    
 
    mutating func findObra(id: UUID){
        if let index = obrasDesconhecidas.firstIndex(where: {$0.id == id}){
            obrasConhecidas.append(obrasDesconhecidas[index])
            obrasDesconhecidas.remove(at: index)
        }
    }
   
    mutating func rollObra() -> ArtEntity? {
        guard let obraSorteada = obrasDesconhecidas.randomElement() else {
            return nil
        }
        findObra(id: obraSorteada.id)
        return obraSorteada
    }
}
